module Flexo
  # Represents a cache file. Keeps track of the contents of each sprite and
  # provides an easy means of determining if the sprite has been changed since
  # the cache was last generated.
  class Cache

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
    # If no +path+ is given, the cache will operate in-memory only and +write+
    # is disabled.
    #
    # @param [Pathname] path
    #   Path to the cache file to be loaded.
    #
    def initialize(path = nil)
      @path = path

      if @path and @path.file?
        @cache = YAML.load_file @path
      else
        @cache = { :cache_version => 2, :sprites => {} }
      end
    end

    # Checks whether the given +sprite+ is different to the cached version.
    #
    # @param [Flexo::Sprite] sprite
    #   The sprite whose "freshness" is to be checked.
    #
    # @return [Boolean]
    #
    def stale?(sprite)
      not fresh?(sprite)
    end

    # Checks whether the given +sprite+ is identical to the cached version.
    #
    # @param [Flexo::Sprite] sprite
    #   The sprite whose "freshness" is to be checked.
    #
    # @return [Boolean]
    #
    def fresh?(sprite)
      sprite.save_path.file? and
        @cache[:sprites].has_key?(sprite.name) and
        @cache[:sprites][sprite.name] == sprite.digest
    end

    # Updates the cached value of +sprite+.
    #
    # @param [Flexo::Sprite] sprite
    #   The sprite whose digest is to be stored in the cache.
    #
    def set(sprite)
      @cache[:sprites][sprite.name] = sprite.digest
    end

    # Removes a +sprite+'s cached values.
    #
    # @param [Flexo::Sprite] sprite
    #   The sprite whose digest is to be removed from the cache.
    #
    def remove(sprite)
      @cache[:sprites].delete(sprite.name)
    end

    # Removes all sprite cache entries, except those in +retain+.
    #
    # @param [Array<Flexo::Cache>] retain
    #   An array of cache entries which are _not_ to be removed.
    #
    def remove_all_except(retain)
      names = retain.map { |sprite| sprite.name }

      @cache[:sprites].delete_if do |key, _|
        not names.include?(key)
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

  end # Cache
end # Flexo
