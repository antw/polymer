require 'rbconfig'
require 'tempfile'

module Polymer
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
        @project_dir ||= Pathname.new(Dir.mktmpdir).realpath
      end

      def project_dir
        @project_dir || self.class.project_dir
      end

      def self.cleanup!
        FileUtils.remove_entry_secure(project_dir) if project_dir.directory?
      end

      def cleanup!
        if @project_dir and @project_dir.directory?
          FileUtils.remove_entry_secure(@project_dir)
        end
      end

      # ----------------------------------------------------------------------

      # Creates a new project helper.
      #
      # @param [Pathname] project_dir
      #   An optional directory in which the helper should create a project.
      #   This is normally handled automatically; if you supply a directory
      #   path, remember to call cleanup! once done.
      #
      def initialize(project_dir = nil)
        @project_dir = project_dir unless project_dir.nil?

        # Wipe out the temporary directory to ensure
        # we have a clean state before each run.
        self.class.cleanup! unless @project_dir
        self.project_dir.mkpath

        self.sources_path = "sources"
        self.sprites_path = "sprites"
      end

      # An alternative to ProjectHelper.new -- creates the helper, and writes
      # the simple configuration.
      #
      # @see ProjectHelper#initialize.
      #
      def self.go!(project_dir = nil)
        helper = new(project_dir)
        helper.write_simple_config
        helper
      end

      def sources_path=(path)
        @sources_path_raw = path
        @sources_path = Pathname.new(path)
      end

      def sprites_path=(path)
        @sprites_path_raw = path
        @sprites_path = Pathname.new(path)
      end

      # Returns a project instance representing the contents of the test
      # directory.
      #
      # @return [Polymer::Project]
      #
      def project
        DSL.load(Project.find_config(project_dir))
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

      # Writes .polymer file in the project root with the given contents.
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
          contents, to = to, '.polymer'
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
      def write_simple_config(to = '.polymer')
        write_config to, <<-CONFIG
          sprites '#{@sources_path_raw}/:name/*' =>
                  '#{@sprites_path_raw}/:name.png'
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
        write_image path_to_source(name), width, height
      end

      # Writes an image at the given path.
      #
      # @param [String, Pathname] path
      #   Path where an image is to be created, relative to the
      #   project root. If a pathname is given, it will be used
      #   regardless of it's location.
      # @param [Integer] width
      #   The width of the source file in pixels.
      # @param [Integer] height
      #   The height of the source file in pixels.
      #
      def write_image(path, width = 50, height = 20)
        path = project_dir + path unless path.kind_of?(Pathname)

        # Create the sources directory.
        path.dirname.mkpath

        Magick::Image.new(width, height) do
          self.background_color = '#CCC'
        end.write(path)

        unless path.file?
          raise "Image '#{path}' was not successfully saved"
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
      def touch(*paths)
        paths.each do |path|
          (project_dir + path).dirname.mkpath
          FileUtils.touch(project_dir + path)
        end
      end

      # Evaluates the given block within the project directory.
      #
      # @param [String] dir
      #   An optional sub-directory in which to run the command.
      #
      def in_project_dir(dir = '')
        project_dir.join(dir).mkpath unless dir.empty?
        Dir.chdir(project_dir + dir) { yield }
      end

    end # ProjectHelper
  end # Spec
end # Polymer
