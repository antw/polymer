module Polymer
  # Represents a directory in which it is expected that there be a
  # configuration file, and source images.
  #
  # The Project class exists mostly to make CLI tasks simpler; if you're using
  # Polymer within your own library, you may prefer to create Sprite instances
  # without using a Project.
  #
  class Project

    # Defaults used by DSL when the user doesn't provide explicit values.
    DEFAULTS = {
      :sass    => 'public/stylesheets/sass',
      :url     => "/images/:name.png",
      :cache   => '.polymer-cache',
      :css     => false,
      :padding => 20
    }

    # Returns the path to the project root directory.
    #
    # @return [Pathname]
    #
    attr_reader :root

    # @return [Pathname, false]
    #   The path to the Sass mixin file.
    # @return [false]
    #   False if Sass has been disabled.
    #
    attr_reader :sass

    # @return [Pathname, false]
    #   The path to the CSS file.
    # @return [false]
    #   False if CSS generation has been disabled.
    #
    attr_reader :css

    # An array containing all of the sprites in the project.
    #
    # @return [Array<Polymer::Sprite>]
    #
    attr_reader :sprites

    # Creates a new Project.
    #
    # Note that +new+ does not validation of the given paths or options; it
    # expects them to be correct. You're probably better using +DSL.build+.
    #
    # @param [Pathname] root_path
    #   Path to the root of the Polymer project. The .polymer config should
    #   reside in this directory.
    # @param [Array<Polymer::Sprite>] sprites
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
      @root      = root_path
      @sprites   = sprites

      @sass      = extract_path :sass,  options
      @css       = extract_path :css,   options
      @cachefile = extract_path :cache, options
    end

    # Returns the sprite whose name is +name+.
    #
    # @param [String] name
    #   The name of the sprite to be retrieved.
    #
    # @return [Polymer::Sprite] The sprite.
    # @return [nil]           If no such sprite exists.
    #
    def sprite(name)
      sprites.detect { |sprite| sprite.name == name }
    end

    # Returns if the cache should be used.
    #
    # @return [true]  If the cache should be used by CLI.
    # @return [false] If the cache is disabled and should not be used.
    #
    def use_cache?
      !! @cachefile
    end

    # Returns a Cache instance for this project.
    #
    # @return [Polymer::Cache]
    #
    def cache
      @cache ||= Polymer::Cache.new(@cachefile)
    end

    private # ================================================================

    # Extracts a path, typically specified in the DSL, and converts it to
    # an absolute Pathname (by appending it on to +@root+).
    #
    # @param [Symbol] key
    #   The option key in which the value is expected.
    # @param [Hash] options
    #   The options hash passed to #initialize.
    #
    # @return [Pathname]
    #   Returns the path appended to +@root+.
    # @return [false, nil]
    #   When the option value was not a string.
    #
    def extract_path(key, options)
      value = options.fetch(key, DEFAULTS[key])
      value.is_a?(String) ? @root + value : value
    end

    # === Class Methods ======================================================

    # Given a path to a directory, +find_config+ attempts to locate a
    # suitable configuration file by looking for a ".polymer" or "polymer.rb"
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
    # @raise [Polymer::MissingProject]
    #   Raised when +find_config+ could not find a suitable configuration
    #   file.
    #
    def self.find_config(path)
      path, config_path = Pathname.new(path).expand_path, nil
      return path if path.file?

      path.ascend do |directory|
        if (dot_polymer = directory + '.polymer').file?
          return dot_polymer
        elsif (polymer_rb = directory + 'polymer.rb').file?
          return polymer_rb
        end
      end

      raise MissingProject,
        "Polymer couldn't find a configuration file at `#{path.to_s}'"
    end

  end # Project
end # Polymer
