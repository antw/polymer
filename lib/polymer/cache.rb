module Polymer
  # Represents a cache file. Keeps track of the contents of each sprite and
  # provides an easy means of determining if the sprite has been changed since
  # the cache was last generated.
  class Cache

    # The highest cache version supported by Cache.
    CACHE_VERSION = 3

    # The default cache.
    EMPTY_CACHE = {
      :cache_version => CACHE_VERSION,
      :sprites       => {},
      :paths         => {}
    }

    # If the first three characters of a path match this, the path isn't
    # in a subtree of the project.
    NON_SUBTREE = '../'.freeze

    # Returns the path to the cache file.
    #
    # @return [Pathname]
    #
    attr_reader :path

    # Creates a new Cache.
    #
    # If the given +path+ does not exist, an empty cache instance will be
    # created, and calling +write+ will create a new file at +path+.
    #
    # @param [Pathname] path
    #   Path to the cache file to be loaded. If no +path+ is given, the cache
    #   will operate in-memory only and +write+ is disabled.
    #
    def initialize(path = nil)
      @path = path

      if @path and @path.file?
        @cache = YAML.load_file @path
        @cache = EMPTY_CACHE if @cache[:cache_version] < CACHE_VERSION
      else
        @cache = EMPTY_CACHE
      end
    end

    # Checks whether the given +sprite+ is different to the cached version.
    #
    # @param [Polymer::Sprite] thing
    #   The sprite or path whose "freshness" is to be checked.
    #
    # @return [Boolean]
    #
    def stale?(thing)
      not fresh?(thing)
    end

    # Checks whether the given +thing+ is identical to the cached version.
    #
    # @param [Polymer::Sprite, Pathname] thing
    #   The sprite or path whose "freshness" is to be checked.
    #
    # @return [Boolean]
    #
    def fresh?(thing)
      return false if thing.is_a?(Sprite)   and not thing.save_path.file?
      return false if thing.is_a?(Pathname) and not thing.cleanpath.file?

      @cache[section(thing)][key(thing)] == digest(thing)
    end

    # Updates the cached value of +thing+.
    #
    # @param [Polymer::Sprite, Pathname] thing
    #   The sprite or Pathname whose digest is to be stored in the cache.
    #
    def set(thing)
      @cache[section(thing)][key(thing)] = digest(thing)
    end

    # Removes a +sprite+'s cached values.
    #
    # @param [Polymer::Sprite, Pathname] thing
    #   The sprite or Pathname whose digest is to be removed from the cache.
    #
    def remove(thing)
      @cache[section(thing)].delete(key(thing))
    end

    # Removes any sprites no longer present in a project, and any cached
    # images which cannot be located.
    #
    # @param [Polymer::Project] project
    #
    def clean!(project)
      return false unless @path

      @cache[:paths].delete_if do |key, _|
        not @path.dirname.join(key).file? or
        # Remove any path to a file not in a subtree (:data_uri images).
        key[0..2] == NON_SUBTREE
      end

      sprite_keys = project.sprites.map { |sprite| key(sprite) }

      @cache[:sprites].delete_if do |key, _|
        not sprite_keys.include?(key)
      end
    end

    # Writes the cache file to disk.
    #
    # @return [true]
    #   Returnss true once the file has been written.
    # @return [false]
    #   Returns false if the Cache was initialized without a path (and, as
    #   such, nothing can be saved).
    #
    def write
      return false unless @path

      @path.open('w') do |file|
        file.puts YAML.dump(@cache)
      end

      true
    end

    #######
    private
    #######

    # @return [Symbol]
    #   Returns the cache section (:sprites or :paths) for the given object.
    def section(thing)
      thing.is_a?(Pathname) ? :paths : :sprites
    end

    # @return [String]
    #   Returns the key which represents the given Sprite or Pathname in the
    #   cache file.
    def key(thing)
      if thing.is_a?(Pathname)
        if @path
          # Store Pathnames as relative to the cache.
          Pathname.pwd.join(thing).relative_path_from(@path.dirname).to_s
        else
          thing.cleanpath.to_s
        end
      else
        thing.name.to_s
      end
    end

    # @return [String]
    #   Returns the SHA256 digest of the given Pathname or Sprite.
    def digest(thing)
      if thing.is_a?(Pathname)
        Digest::SHA256.file(thing.cleanpath).to_s
      else
        thing.digest
      end
    end

  end # Cache
end # Polymer
