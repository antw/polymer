module Montage
  # Represents a directory in which it is expected that there be a
  # configuration file, and source images.
  class Project
    DEFAULTS = {
      :sources     => 'public/images/sprites/src',
      :sprites     => 'public/images/sprites',
      :css         => 'public/stylesheets',
      :sass        => 'public/stylesheets/sass',
      :sprite_url  => '/images/sprites'
    }

    # Stores all the paths the project needs.
    Paths = Struct.new(:root, :config, :sources, :sprites, :css, :sass, :url)

    # Returns the Paths instance for the project.
    #
    # @return [Montage::Project::Paths]
    #
    attr_reader :paths

    # Returns an Array containing all the Sprites defined in the project.
    #
    # @return [Array<Montage::Sprite>]
    #
    attr_reader :sprites

    # Creates a new Project instance.
    #
    # Note that +new+ does no validation of the given paths: it expects them
    # to be correct. If you're not sure of the exact paths, use +Project.find+
    # instead.
    #
    # @param [String, Pathname] root_path
    #   Path to the root of the Montage project.
    # @param [String, Pathname] config_path
    #   Path to the config file.
    #
    def initialize(root_path, config_path)
      root_path   = Pathname.new(root_path)
      config_path = Pathname.new(config_path)

      config = YAML.load_file(config_path)

      @paths = Paths.new(
        root_path, config_path,
        root_path + (config.delete('config.sources')    || DEFAULTS[:sources]),
        root_path + (config.delete('config.sprites')    || DEFAULTS[:sprites]),
        root_path + (config.delete('config.css')        || DEFAULTS[:css]),
        root_path + (config.delete('config.sass')       || DEFAULTS[:sass]),
                    (config.delete('config.sprite_url') || DEFAULTS[:sprite_url])
      )

      # All remaining config keys are sprite defintions.
      @sprites = config.inject([]) do |sprites, (name, sources)|
        sprites << Sprite.new(name, sources, @paths.sources)
      end
    end

    # Returns a particular sprite identified by +name+.
    #
    # @param [String] name
    #   The name of the sprite to be retrieved.
    #
    # @return [Montage::Sprite]
    #
    def sprite(name)
      sprites.detect { |sprite| sprite.name == name }
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
      # @param [String, Pathname] path
      #   Path to the configuration or directory.
      #
      # @return [Montage::Project]
      #   Returns the project.
      #
      # @raise [MissingProject]
      #   Raised when a project directory couldn't be found.
      #
      def find(path)
        path = Pathname(path).expand_path
        config_path, root_path = nil, nil

        if path.file?
          root_path = find_root(path)
          config_path = path
        elsif path.directory?
          if config_path = find_config(path)
            root_path = path
          else
            # Assume we're in a subdirectory of the current project.
            path.split.first.ascend do |directory|
              if config_path = find_config(directory)
                break if root_path = find_root(config_path)
              end
            end
          end
        end

        raise MissingProject, "Montage couldn't find a project to work " \
          "on at `#{path}'" if root_path.nil?

        new(root_path, config_path)
      end

      # Sets up a new project file structure.
      #
      # @param [String, Pathname] dir
      #   Path to the project root.
      #
      # @return [Montage::Project]
      #   Returns the Project instance representing the created project.
      #
      def init(dir)
        dir = Pathname.new(dir)

        begin
          found = find(dir)
        rescue MissingProject
          if (dir + 'config').directory?
            config_path = dir + 'config/montage.yml'
          else
            config_path = dir + 'montage.yml'
          end

          template = (Pathname.new(__FILE__).dirname + 'templates/montage.yml')
          FileUtils.cp(template, config_path)

          new(dir, config_path)
        else
          raise ProjectExists, "A Montage project exists in a " \
            "parent directory at `#{found.paths.root}'"
        end
      end

      private

      # Attempt to find the configuration file, first by looking in
      # ./montage.yml, then ./config/montage.yml
      #
      # @return [String]
      #
      def find_config(dir)
        config_paths = [ dir + 'montage.yml', dir + 'config/montage.yml' ]
        config_paths.detect { |config| config.file? }
      end

      # Attempts to find the project root for the configuration file. If the
      # config file is in a directory called 'config' then the project root is
      # assumed to be one level up.
      #
      # @return [String]
      #
      def find_root(config)
        config_dir = config.dirname

        if config_dir.split.last.to_s == 'config'
          (config_dir + '..').expand_path
        else
          config_dir
        end
      end

    end # class << self
  end # Project
end # Montage
