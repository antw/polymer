module Montage
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
        new(Montage::Project.find(Dir.pwd),
            Montage::Commands.config[:force]).run!

      rescue Montage::MissingProject
        say color(<<-ERROR.compress_lines, :red)
          Couldn't find a Montage project in the current directory. If
          you want to create a new project here, run `montage init'.
        ERROR

        exit(1)

      rescue Montage::MissingSource, Montage::TargetNotWritable => e
        say Montage::Commands::BLANK
        say color(e.message.compress_lines, :red)

        exit(1)
      end

      # Creates a new Generate instance.
      #
      # @param [Montage::Project] project
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
        end
      end

      private # ==============================================================

      # Returns the cached digests.
      #
      # @return [Hash]
      #
      def cache
        @_sprite_caches ||= begin
          cache_path = @project.paths.sprites + '.montage_cache'
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
        unless @project.paths.sprites.directory?
          @project.paths.sprites.mkpath
        end

        @project.sprites.each do |sprite|
          digest = sprite.digest


          if @force or cache[sprite.name] != digest or not sprite.path.file?
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

        say Montage::Commands::BLANK
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
            Skipping optimisation with PNGOut since Montage couldn't find
            "pngout" or "pngout-darwin" anywhere.
          MESSAGE
          say Montage::Commands::BLANK

          return
        end

        max_sprite_name_length = @generated.inject(0) do |max, sprite|
          max > sprite.name.length ? max : sprite.name.length
        end

        @generated.each do |sprite|
          original_size = sprite.path.size

          with_feedback %(Optimising "#{sprite.name}"), 'Optimising' do
            5.times do |i|
              # Optimise until pngout reports that it can't compress further,
              # or until we've tried five times.
              out = `#{pngout} #{sprite.path} #{sprite.path} -s0 -k0 -y`
              break if out =~ /Unable to compress further/
            end
          end

          new_size  = sprite.path.size

          reduction = ('%.1fkb (%d' % [
            (original_size.to_f - new_size) / 1024,
            100 - (new_size.to_f / original_size) * 100 ]) + '%)'

          say color("Done; saved #{reduction}", :green)
        end

        say Montage::Commands::BLANK

      rescue Errno::ENOENT
        say ("#{RESET}" + <<-MESSAGE.compress_lines)
          Skipping optimisation with PNGOut since Montage is currently only in
          bed with Linux and OS X. Sorry!
        MESSAGE
        say Montage::Commands::BLANK
        exit(1)
      end

      # Step 3: Writes the cached digests to the cache file.
      #
      def write_cache!
        cache_path = @project.paths.sprites + '.montage_cache'

        File.open(cache_path, 'w') do |cache_writer|
          cache_writer.puts YAML.dump(cache)
        end
      end

      # Step 4: Writes the Sass file to disk.
      #
      def write_sass!
        unless @project.paths.sass == false
          say "- Generating Sass: "
          Montage::SassBuilder.new(@project).write
          say color("Done", :green)
          say Montage::Commands::BLANK
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

    end # Generate
  end # Commands
end # Montage
