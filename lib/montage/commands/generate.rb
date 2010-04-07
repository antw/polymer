module Montage
  module Commands
    # Generates sprites for a project.
    class Generate
      extend Commands

      # Given a project, generates sprites.
      #
      # @param [Array] argv
      #   The arguments given on the command line.
      #
      def self.run(argv)
        new(Montage::Project.find(Dir.pwd), argv.include?('--force')).run!

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
          say "- #{sprite.name}: "

          if @force or cache[sprite.name] != digest or not sprite.path.file?
            sprite.write
            cache[sprite.name] = digest
            @generated << sprite
            say color("Generated ", :green)
          else
            say color("Unchanged: ignoring", :yellow)
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
        end

        max_sprite_name_length = @generated.inject(0) do |max, sprite|
          max > sprite.name.length ? max : sprite.name.length
        end

        @generated.each do |sprite|
          notifier = Thread.new do
            run_optimisation_notifier(sprite, max_sprite_name_length)
          end

          optimiser = Thread.new do
            5.times do |i|
              # Optimise until pngout reports that it can't compress further,
              # or until we've tried five times.
              out = `#{pngout} #{sprite.path} #{sprite.path} -s0 -k0 -y`
              break if out =~ /Unable to compress further/
            end

            notifier.kill
          end

          notifier.join
          optimiser.join
        end

        say Montage::Commands::BLANK

      rescue Errno::ENOENT
        say <<-MESSAGE.compress_lines
          Skipping optimisation with PNGOut since Montage is currently only in
          bed with Linux and OS X. Sorry!
        MESSAGE
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
          Montage::SassBuilder.new(@project).write
          say color("- Generated Sass", :green)
          say Montage::Commands::BLANK
        end
      end

      # --- Optimisation Output ----------------------------------------------

      # Outputs nice messages to the user while a sprite is optimised.
      #
      # optimise_with_pngout! runs this in a thread, killing it once the
      # optimisation has been completed.
      #
      # @param [Montage::Sprite] sprite
      #   The sprite being optimised.
      # @param [Integer] max_sprite_length
      #   The length of the longest sprite name -- allows us to justify
      #   messages.
      #
      def run_optimisation_notifier(sprite, max_sprite_length)
        reset, iteration = "\r\e[0K", 0

        original_size = sprite.path.size

        messages = {
          0  => "Optimising",                       # initial message
          30 => "Still optimising...",              # after 3 seconds
          60 => "STILL optimising...",              # after 6 seconds
          90 => "Gosh, this is taking a while..." } # after 9 seconds

        glyphs = %w( ~ \\ | / )
        prefix = %(- Optimising "#{sprite.name}": )

        while true do
          message = color(messages[iteration], :blue) if messages[iteration]

          say "#{reset}#{prefix}#{message} [#{glyphs[iteration % 4]}] "

          iteration += 1
          $stdout.flush
          sleep(0.1)
        end
      ensure
        # This gets run when the thread is killed, meaining optimisation
        # has finished.

        new_size  = sprite.path.size

        reduction = ('%.1fkb (%d' % [
          (original_size.to_f - new_size) / 1024,
          100 - (new_size.to_f / original_size) * 100 ]) + '%)'

        message = "Done; saved #{reduction}"
        say "#{reset}#{prefix}#{color(message, :green)}"
      end

    end # Generate
  end # Commands
end # Montage
