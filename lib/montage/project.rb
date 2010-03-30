module Montage
  # Represents a directory in which it is expected that there be a
  # configuration file, and source images.
  class Project
    DEFAULTS = {
      :sources     => 'public/images/sprites/src',
      :output      => 'public/images/sprites',
      :css_output  => 'public/stylesheets',
      :sass_output => 'public/stylesheets/sass',
      :sprite_url  => '/images/sprites'
    }

    # Stores all the paths the project needs.
    Paths = Struct.new(:root, :config, :sources, :output, :css, :sass, :url)

    # Returns the Paths instance for the project.
    #
    # @return [Montage::Project::Paths]
    #
    attr_reader :paths

    # Creates a new Project instance.
    #
    # Note that +new+ does no validation of the given paths: it expects them
    # to be correct. If you're not sure of the exact paths, use +Project.find+
    # instead.
    #
    # @param [String] root
    #   Path to the root of the Montage project.
    # @param [String] config
    #   Path to the config file.
    #
    def initialize(root, config)
      montage_yml = YAML.load_file(config)
      conf = montage_yml['config'] || {}

      @paths = Paths.new(
        root, config,
        File.join(root, conf.fetch('sources',     DEFAULTS[:sources])),
        File.join(root, conf.fetch('output',      DEFAULTS[:output])),
        File.join(root, conf.fetch('css_output',  DEFAULTS[:css_output])),
        File.join(root, conf.fetch('sass_output', DEFAULTS[:sass_output])),
        conf.fetch('sprite_url', DEFAULTS[:sprite_url])
      )
    end

    private

    def path_for(root_path, config, key)
      File.join(root_path, config.fetch(key.to_s, DEFAULTS[key]))
    end

    class << self

      # Given a path to a directory, or config file, attempts to find the
      # Montage root.
      #
      # If given a path to a file:
      #
      #   * Montage assumes that the file is the configuration.
      #
      #   * The root directory is assumed to be the same directory as the one
      #     in which the configuration resides _unless_ the directory is
      #     called 'config', in which case the root is considered to be the
      #     parent directory.
      #
      # If given a path to a directory:
      #
      #   * Montage will look for montage.yml, or config/montage.yml.
      #
      #   * If a configuration couldn't be found, +find+ looks in the next
      #     directory up. It continues until it finds a valid project or runs
      #     out of parent directories.
      #
      # @param [String] path
      #   Path to the configuration or directory.
      #
      # @return [Montage::Project]
      #   Returns the project.
      #
      # @raise [MissingProject]
      #   Raised when a project directory couldn't be found.
      #
      def find(dir)
        dir = File.expand_path(dir)

        if File.directory?(dir)
          if config_file = find_config(dir)
            root = dir
          else
            # Assume we're in a subdirectory of the current project.
            tokens = dir.split(%r{/|\\})
            while tokens.pop
              config_file = find_config(File.join(*tokens))
              root = find_root(config_file) if config_file
              break if root
            end
          end
        elsif File.file?(dir)
          root, config_file = find_root(dir), dir
        end

        raise MissingProject,
          "Montage couldn't find a project to work on at #{dir}" if root.nil?

        new(root, config_file)
      end

      # Sets up a new project file structure.
      #
      # @param [String] dir
      #   Path to the project root.
      #
      # @return [Montage::Project]
      #   Returns the Project instance representing the created project.
      #
      def init(dir)
        begin
          found = find(dir)
        rescue MissingProject
          # Hurrah!
        else
          raise ProjectExists, "A Montage project exists in a " \
            "parent directory at `#{found.paths.root}'"
        end

        config_path = if File.directory?(File.join(dir, 'config'))
          File.join(dir, 'config', 'montage.yml')
        else
          File.join(dir, 'montage.yml')
        end

        FileUtils.cp(
          File.join(File.dirname(__FILE__), 'templates', 'montage.yml'),
          config_path)

        new(dir, config_path)
      end

      private

      # Attempt to find the configuration file, first by looking in
      # ./montage.yml, then ./config/montage.yml
      #
      # @return [String]
      #
      def find_config(dir)
        config_paths = [
          File.join(dir, 'montage.yml'),
          File.join(dir, 'config', 'montage.yml') ]

        config_paths.detect { |config| File.file?(config) }
      end

      # Attempts to find the project root for the configuration file. If the
      # config file is in a directory called 'config' then the project root is
      # assumed to be one level up.
      #
      # @return [String]
      #
      def find_root(config)
        config_dir = File.dirname(config)

        if config_dir.split(%r{/|\\}).last == 'config'
          File.expand_path(File.join(config_dir, '..'))
        else
          config_dir
        end
      end

    end # class << self
  end # Project
end # Montage
