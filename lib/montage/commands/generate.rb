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
      def self.run(*)
        new(Montage::Project.find(Dir.pwd)).run!

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
      # @param [Montage::Project]
      #   The project whose sprites are to be generated.
      #
      def initialize(project)
        @project = project
      end

      # Runs the generator, saving the sprites and cache.
      #
      def run!
        if generate_sprites!
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

        updated = false

        @project.sprites.each do |sprite|
          digest = sprite.digest
          say "#{sprite.name}: "

          if cache[sprite.name] != digest or not sprite.path.file?
            sprite.write
            cache[sprite.name] = digest
            updated = true
            say color("Generated", :green)
          else
            say color("Unchanged: ignoring", :yellow)
          end
        end

        say Montage::Commands::BLANK
        updated
      end

      # Step 2: Writes the cached digests to the cache file.
      #
      def write_cache!
        cache_path = @project.paths.sprites + '.montage_cache'

        File.open(cache_path, 'w') do |cache_writer|
          cache_writer.puts YAML.dump(cache)
        end
      end

      # Step 3: Writes the Sass file to disk.
      #
      def write_sass!
        unless @project.paths.sass == false
          Montage::SassBuilder.new(@project).write
          say color("Generated Sass", :green)
        end
      end

    end # Generate
  end # Commands
end # Montage
