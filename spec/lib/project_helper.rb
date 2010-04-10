require 'rbconfig'
require 'tempfile'

module Montage
  module Spec
    # Provides useful functionality for dealing with temporary project
    # directories when running tests.
    #
    # Any helper classes which use ProjectHelper will always run in a single
    # temporary directory (which is removed and recreated each time) and thus
    # doesn't need to be cleaned up afterwards.
    #
    class ProjectHelper

      # --- Class methods ----------------------------------------------------

      def self.project_dir
        @project_dir ||= Pathname.new(Dir.mktmpdir)
      end

      def project_dir
        self.class.project_dir
      end

      def self.cleanup!
        FileUtils.remove_entry_secure(project_dir) if project_dir.directory?
      end

      # ----------------------------------------------------------------------

      def initialize
        # Wipe out the temporary directory to ensure
        # we have a clean state before each run.
        self.class.cleanup!
        project_dir.mkpath

        self.sources_path = "public/images/sprites/src"
        self.sprites_path = "public/images/sprites"
      end

      def sources_path=(path)
        @sources_path = Pathname.new(path)
      end

      def sprites_path=(path)
        @sprites_path = Pathname.new(path)
      end

      # Returns a project instance representing the contents of the test
      # directory.
      #
      # @return [Montage::Project]
      #
      def project
        Project.find(project_dir)
      end

      # --- Paths ------------------------------------------------------------

      # Returns the path to a file.
      #
      # @param [String] name
      #   The name of the source file.
      #
      def path_to_file(name)
        (project_dir + name).expand_path
      end

      # Returns the path to a source file (sans extension).
      #
      # @param [String] name
      #   The name of the source file.
      #
      def path_to_source(name)
        path_to_file @sources_path + "#{name}.png"
      end

      # Returns the path to a sprite file (sans extension).
      #
      # @param [String] name
      #   The name of the sprite file.
      #
      def path_to_sprite(name)
        path_to_file @sprites_path + "#{name}.png"
      end

      # --- File Writers -----------------------------------------------------

      # Writes .montage file in the project root with the given contents.
      #
      # @param [String] to
      #   The path at which to save the config file. Or: The file contents if
      #   you want to save at the default location.
      # @param [String] contents
      #   The contents to be saved as the config file.
      #
      def write_config(to, contents = nil)
        if contents.nil?
          # Sigh; if only 1.9 was more popular...
          contents, to = to, '.montage'
        else
          (project_dir + to).dirname.mkpath
        end

        File.open(project_dir + to, 'w') do |file|
          file.puts contents.unindent
        end
      end

      # Writes a simple config file.
      #
      # @param [String] to
      #   The path at which to save the config file.
      #
      def write_simple_config(to = '.montage')
        write_config to, <<-CONFIG
          ---
            sprite_one:
              - source_one
        CONFIG
      end

      # Writes a source image file to the src directory.
      #
      # @param [String] name
      #   The name of the source image file, sans extension.
      # @param [Integer] width
      #   The width of the source file in pixels.
      # @param [Integer] height
      #   The height of the source file in pixels.
      #
      def write_source(name, width = 50, height = 20)
        source_path = path_to_source(name)

        # Create the sources directory.
        source_path.dirname.mkpath

        Magick::Image.new(width, height) do
          self.background_color = '#CCC'
        end.write(source_path)

        unless source_path.file?
          raise "Source #{name} was not successfully saved"
        end
      end

      # Creates a directory in the project.
      #
      # @param [String] path
      #   Path to the directory, relative to the project root.
      #
      def mkdir(path)
        (project_dir + path).mkpath
      end

      # Creates an empty file.
      #
      # @param [String] path
      #   Path to the file to be touched.
      #
      def touch(path)
        (project_dir + path).dirname.mkpath
        FileUtils.touch(project_dir + path)
      end

    end # ProjectHelper
  end # Spec
end # Montage
