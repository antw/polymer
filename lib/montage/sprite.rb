module Montage
  # Represents a collection of images which will be used to make a sprite.
  #
  class Sprite
    # Creates a new Sprite instance.
    #
    # @param [String] name
    #   The name of the sprite. Will be used as the sprite filename (with an
    #   extension added).
    # @param [Array<String>] sources
    #   The name of each source image.
    # @param [Pathname] dir
    #   The directory in which the source images are stored.
    #
    def initialize(name, sources, dir)
      @name, @sources, @dir = name, sources, dir
    end

    # Returns an array of paths to the source files. A MissingSource error
    # will be raised if a source image could not be found.
    #
    # @return [Array<Pathname>]
    #
    def paths
      @paths ||= resolve_paths!
    end

    # Returns an array of RMagick image instances; one for each source.
    #
    # @return [Array<Magick::Image>]
    #   The Image instances for the sources.
    #
    def images
      @images ||= paths.map { |source| Magick::Image.read(source).first }
    end

    private

    # Resolves the source names into full file paths (with extensions).
    #
    def resolve_paths!
      entries = @dir.entries.inject({}) do |hash, path|
        hash[ path.to_s.chomp(path.extname) ] = @dir + path ; hash
      end

      @sources.map do |source|
        unless entries.key?(source)
          raise MissingSource, <<-MESSAGE.compress_lines
            Couldn't find a matching file for source image `#{source}' as part
            of the `#{@name}' sprite.
          MESSAGE
        end

        entries[source]
      end
    rescue Errno::ENOENT
      raise MissingSource, <<-MESSAGE.compress_lines
        Couldn't find the source directory for the `#{@name}' sprite. Montage
        was looking for #{@dir}; if your sprites are in a different location,
        add a 'config.sources' option your config file.
      MESSAGE
    end

  end # Set
end # Montage
