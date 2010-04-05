module Montage
  module Commands
    # Generates sprites for a project.
    class Generate
      extend  Commands
      extend  Term::ANSIColor
      include Term::ANSIColor

      # Given a project, generates sprites.
      #
      # @param [Array] argv
      #   The arguments given on the command line.
      #
      def self.run(*)
        new(Montage::Project.find(Dir.pwd)).run!

      rescue Montage::MissingProject
        $stdout.puts red(<<-ERROR)
          Couldn't find a Montage project in the current directory. If
          you want to create a new project here, run `montage init'.
        ERROR

        exit(1)

      rescue Montage::MissingSource, Montage::TargetNotWritable => e
        $stdout.puts
        $stdout.puts
        $stdout.puts red(e.message)

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
        generate_sprites!
        write_cache!
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

      # Generates the sprites for the given project. Skips those which have
      # not changed since they were last generated.
      #
      # @param [Montage::Project] project
      #   The project whose sprites are to be generated.
      # @param [Hash] cache
      #   The cached digests for the project.
      #
      def generate_sprites!
        @project.sprites.each do |sprite|
          digest = sprite.digest
          $stdout.print "#{sprite.name}: "

          if cache[sprite.name] == digest
            $stdout.puts yellow("Unchanged: ignoring")
          else
            sprite.write
            cache[sprite.name] = digest
            $stdout.puts green("Generated")
          end
        end
      end

      # Writes the cached digests to the cache file.
      #
      # @param [Pathname] montage_cache
      #   Path to the cache file.
      # @param [Hash] cache
      #   A hash of sprite names and their calculated digests.
      #
      def write_cache!
        cache_path = @project.paths.sprites + '.montage_cache'

        File.open(cache_path, 'w') do |cache_writer|
          cache_writer.puts YAML.dump(cache)
        end
      end

    end # Generate
  end # Commands
end # Montage
