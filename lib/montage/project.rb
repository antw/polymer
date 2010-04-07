module Montage
  # Represents a directory in which it is expected that there be a
  # configuration file, and source images.
  class Project
    DEFAULTS = {
      :sources     => 'public/images/sprites/src',
      :sprites     => 'public/images/sprites',
      :sass        => 'public/stylesheets/sass',
      :sprite_url  => '/images/sprites'
    }

    # Stores all the paths the project needs.
    Paths = Struct.new(:root, :config, :sources, :sprites, :sass, :url)

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

    # Returns the amount of space to be used between each source image when
    # saving sprites.
    #
    # @return [Integer]
    #
    attr_reader :padding

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
        extract_path_from_config(config, :sources, root_path),
        extract_path_from_config(config, :sprites, root_path),
        extract_path_from_config(config, :sass,    root_path),
        config.delete('config.sprite_url') { DEFAULTS[:sprite_url] }
      )

      @padding = (config.delete('config.padding') || 20).to_i

      # All remaining config keys are sprite defintions.
      @sprites = config.inject([]) do |sprites, (name, sources)|
        sprites << Sprite.new(name, sources, self)
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

    private # ================================================================

    # Extracts a configuration value from a configuration hash. If the value
    # exists, and is a string, it will be appended to the +root+ path.
    #
    # The configuration item will be _removed_ from the hash.
    #
    # @param [Hash] config    The configuration Hash.
    # @param [Symbol] key     The configuration key.
    # @param [Pathname] root  The project root path.
    #
    # @return [Pathname, false]
    #
    def extract_path_from_config(config, key, root)
      value = config.delete("config.#{key}") { DEFAULTS[key] }
      value.is_a?(String) ? root + value : value
    end

    # === Class Methods ======================================================

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
