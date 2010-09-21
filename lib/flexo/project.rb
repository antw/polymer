module Flexo
  # Represents a directory in which it is expected that there be a
  # configuration file, and source images.
  class Project
    DEFAULTS = {
      :sources => 'public/images/sprites',
      :sprites => 'public/images',
      :sass    => 'public/stylesheets/sass',
      :to      => "public/images/:name.png",
      :url     => "/images/:name.png",
      :cache   => '.flexo-cache',
      :padding => 20
    }

    # Stores all the paths the project needs.
    Paths = Struct.new(:root, :config, :sass, :url, :cache)

    # Returns the path to the project root directory.
    #
    # @return [Pathname]
    #
    attr_reader :root

    # Returns the Paths instance for the project.
    #
    # @return [Flexo::Project::Paths]
    #
    attr_reader :paths

    # Returns an Array containing all the Sprites defined in the project.
    #
    # @return [Array<Flexo::Sprite>]
    #
    attr_reader :sprites

    # Returns the amount of space to be used between each source image when
    # saving sprites.
    #
    # @return [Integer]
    #
    attr_reader :padding

    # Creates a new Project.
    #
    # Note that +new+ does not validation of the given paths or options; it
    # expects them to be correct. You're probably better using +DSL.build+.
    #
    # @param [Pathname] root_path
    #   Path to the root of the Flexo project. The .flexo config should reside
    #   in this directory.
    # @param [Array<Flexo::Sprite>] sprites
    #   An array of sprites which belong to the project.
    # @param [Hash] options
    #   Extra options for customising the behaviour of the Project.
    #
    # @option options [String, false] :css (false)
    #   Sets the path -- relative to +root_path+ -- at which the CSS
    #   file should be saved. Setting +:css+ to false will disable
    #   generation of CSS stylesheets.
    # @option options [String, false] :sass (false)
    #   Sets the path -- relative to +root_path+ -- at which the Sass
    #   mixin file should be saved. Setting +:sass+ to false will
    #   disable generation of the mixin file.
    #
    def initialize(root_path, sprites, options = {})
      @root    = root_path
      @sprites = sprites

      @sass    = extract_path :sass,  options
      @css     = extract_path :css,   options
      @cache   = extract_path :cache, options

      # TEMPORARY until Paths can be removed.
      @paths = Paths.new(
        root_path,                            # root
        root_path + '.flexo',                 # config
        @sass,                                # sass
        options.fetch(:url, DEFAULTS[:url]),  # url
        @cache                                # cache
      )
    end

    # Returns a particular sprite identified by +name+.
    #
    # @param [String] name
    #   The name of the sprite to be retrieved.
    #
    # @return [Flexo::Sprite]
    #
    def sprite(name)
      sprites.detect { |sprite| sprite.name == name }
    end

    private # ================================================================

    # Given the options passed to initialize, takes an option which is
    # expected to be a hash and appends it to the @root. If the value is
    # falsey it is returned without modification. Finally, if the option
    # key does not exist, the default is used.
    #
    # @param [Symbol] key
    #   The option key in which the value is expected.
    # @param [Hash] options
    #   The options hash passed to #initialize.
    #
    # @return [Pathname, false]
    #
    def extract_path(key, options)
      value = options.fetch(key, DEFAULTS[key])
      value.is_a?(String) ? @root + value : value
    end

    # === Class Methods ======================================================

    # Given a path to a directory, +find_config+ attempts to locate a
    # suitable configuration file by looking for a ".flexo" or "flexo.rb"
    # file. If no such file is found in the given directory, it ascends the
    # directory structure until one is found, or it runs out of parent
    # directories to check.
    #
    # If given a path to a file, +find_config+ assumes that this file is the
    # config, and simply returns it as a Pathname.
    #
    # @param [Pathname, String] path
    #   The path to the directory or configuration file.
    #
    # @return [Pathname]
    #   The path to the found configuration.
    #
    # @raise [Flexo::MissingProject]
    #   Raised when +find_config+ could not find a suitable configuration
    #   file.
    #
    def self.find_config(path)
      path, config_path = Pathname.new(path).expand_path, nil
      return path if path.file?

      path.ascend do |directory|
        if (dot_flexo = directory + '.flexo').file?
          return dot_flexo
        elsif (flexo_rb = directory + 'flexo.rb').file?
          return flexo_rb
        end
      end

      raise MissingProject,
        "Flexo couldn't find a configuration file at `#{path.to_s}'"
    end

  end # Project
end # Flexo
