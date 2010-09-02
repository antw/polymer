module Flexo
  module Commands
    # Generates sprites for a project.
    class Generate
      extend Commands

      # Terminal reset code; removes any content on the current line and moves
      # the cursor back to the beginning.
      RESET = "\r\e[0K"

      # Glyphs used when doing long-running processes.
      GLYPHS = %w( ~ \\ | / )

      # Given a project, generates sprites.
      #
      # @param [Array] argv
      #   The arguments given on the command line.
      #
      def self.run(argv)
        # If there are any arguments, the first one is a path to a flexo
        # config file.
        if argv.first and not Pathname.new(argv.first).file?
          say color(<<-ERROR.compress_lines, :red)
            Couldn't find `#{argv.first}' configuration file. Are you
            sure you got the path right?
          ERROR

          exit(1)
        end


        new(Flexo::Project.find(argv.first || Dir.pwd),
            Flexo::Commands.config[:force]).run!

      rescue Flexo::MissingProject
        say color(<<-ERROR.compress_lines, :red)
          Couldn't find a Flexo project in the current directory. If
          you want to create a new project here, run `flexo init'.
        ERROR

        exit(1)

      rescue Flexo::MissingSource, Flexo::TargetNotWritable => e
        say Flexo::Commands::BLANK
        say color(e.message.compress_lines, :red)

        exit(1)
      end

      # Creates a new Generate instance.
      #
      # @param [Flexo::Project] project
      #   The project whose sprites are to be generated.
      # @param [Boolean] force
      #   Rengerate sprites, even if they haven't been changed.
      #
      def initialize(project, force)
        @project, @force, @generated = project, force, []
      end

      # Runs the generator, saving the sprites and cache.
      #
      def run!
        if generate_sprites!
          optimise_with_pngout!
          write_cache!
          write_sass!
          warn_deviants!
        end
      end

      private # ==============================================================

      # Returns the cached digests.
      #
      # @return [Hash]
      #
      def cache
        @_sprite_caches ||= begin
          cache_path = @project.paths.root + '.flexo_cache'
          cache_path.file? ? YAML.load_file(cache_path) || {} : {}
        end
      end

      # Step 1: Generates the sprites for the given project. Skips those which
      # have not changed since they were last generated.
      #
      # @return [Boolean]
      #   Returns true if at least one sprite has been updated.
      #
      def generate_sprites!
        @project.sprites.each do |sprite|
          digest = sprite.digest

          # Ensure that we can write to the output directory.
          unless sprite.save_path.dirname.directory?
            sprite.save_path.dirname.mkpath
          end

          if @force or cache[sprite.name] != digest or
              not sprite.save_path.file?
            with_feedback %(Generating "#{sprite.name}"), 'Generating' do
              sprite.write
              cache[sprite.name] = digest
              @generated << sprite
            end

            say color("Done", :green)
          else
            say %(- Generating "#{sprite.name}": ) +
                color("Unchanged; ignoring", :yellow)
          end
        end

        say Flexo::Commands::BLANK
        @generated.any?
      end

      # Step 2: Optimise generated sprites with PNGOut.
      #
      def optimise_with_pngout!
        return if @generated.empty?

        # Try to find PNGOut.
        pngout = `which pngout pngout-darwin`.split("\n").first

        if pngout.nil?
          say <<-MESSAGE.compress_lines
            Skipping optimisation with PNGOut since Flexo couldn't find
            "pngout" or "pngout-darwin" anywhere.
          MESSAGE
          say Flexo::Commands::BLANK

          return
        end

        max_sprite_name_length = @generated.inject(0) do |max, sprite|
          max > sprite.name.length ? max : sprite.name.length
        end

        @generated.each do |sprite|
          original_size = sprite.save_path.size
          save_path = sprite.save_path

          with_feedback %(Optimising "#{sprite.name}"), 'Optimising' do
            5.times do |i|
              # Optimise until pngout reports that it can't compress further,
              # or until we've tried five times.
              out = `#{pngout} #{save_path} #{save_path} -s0 -k0 -y`
              break if out =~ /Unable to compress further/
            end
          end

          new_size  = save_path.size

          reduction = ('%.1fkb (%d' % [
            (original_size.to_f - new_size) / 1024,
            100 - (new_size.to_f / original_size) * 100 ]) + '%)'

          say color("Done; saved #{reduction}", :green)
        end

        say Flexo::Commands::BLANK

      rescue Errno::ENOENT
        say ("#{RESET}" + <<-MESSAGE.compress_lines)
          Skipping optimisation with PNGOut since Flexo is currently only in
          bed with Linux and OS X. Sorry!
        MESSAGE
        say Flexo::Commands::BLANK
        exit(1)
      end

      # Step 3: Writes the cached digests to the cache file.
      #
      def write_cache!
        cache_path = @project.paths.root + '.flexo_cache'

        File.open(cache_path, 'w') do |cache_writer|
          cache_writer.puts YAML.dump(cache)
        end
      end

      # Step 4: Writes the Sass file to disk.
      #
      def write_sass!
        unless @project.paths.sass == false
          say "- Generating Sass: "
          Flexo::SassBuilder.new(@project).write
          say color("Done", :green)
          say Flexo::Commands::BLANK
        end
      end

      # Step 5: Warn about images which are more than one standard deviation
      # from the mean width.
      #
      def warn_deviants!
        @generated.each do |sprite|
          next if sprite.sources.size < 2

          mean, std_dev = standard_deviation(sprite.sources.map do |source|
            source.image.columns
          end)

          next if std_dev < 100 # Skip relatively narrow images.

          sprite.sources.each do |source|
            width = source.image.columns
            if width > mean + std_dev || width < mean - std_dev
              say <<-MESSAGE.compress_lines
                The "#{source.name}" source image in the "#{sprite.name}"
                sprite deviates significantly from the average width. You
                might want to consider removing this source from the sprite.

                The mean width for sources in this sprite is #{mean}px,
                while this source is #{width}px wide.

              MESSAGE
              say Flexo::Commands::BLANK
            end
          end
        end
      end

      # --- Optimisation Output ----------------------------------------------

      # Executes a block while providing live feedback to the user.
      #
      # @param [String] prefix
      #   The "prefix" of each notification; this is always shown at the
      #   beginning of each line.
      # @param [String] verb
      #   What's happening?
      #
      # @example
      #   with_notification('Generating image', 'Generating') { ... }
      #
      #   # "- Generating image: Generating"       # initially
      #   # "- Generating image: Still generating" # after 3 seconds
      #   # "- Generating image: STILL generating" # after 6 seconds
      #
      def with_feedback(prefix, verb = 'Generating', &work)
        notifier = Thread.new do
          prefix = "- #{prefix}: "
          iteration = 0

          while true do
            case iteration
              when  0 then message = color(verb, :blue)
              when 30 then message = color("Still #{verb.downcase}", :blue)
              when 60 then message = color("STILL #{verb.downcase}", :blue)
              when 90 then message =
                             color("Gosh, this is taking a while...", :blue)
            end

            say "#{RESET}#{prefix}#{message} [#{GLYPHS[iteration % 4]}] "

            iteration += 1
            $stdout.flush
            sleep(0.1)
          end
        end

        worker = Thread.new do
          begin
            work.call
          ensure
            notifier.kill
          end
        end

        notifier.join
        worker.join

        say "#{RESET}#{prefix}"
      end

      # Knuth. via Wikipedia. :/
      def standard_deviation(data)
        n, mean, m2 = 0, 0, 0

        data.each do |x|
          n = n + 1
          delta = x - mean
          mean = mean + delta / n
          m2 = m2 + delta * (x - mean)
        end

        [mean, Math.sqrt(m2 / (n - 1))]
      end

    end # Generate
  end # Commands
end # Flexo
