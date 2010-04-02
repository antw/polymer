module Montage
  # Represents a collection of images which will be used to make a sprite.
  #
  # This would ideally be separate Sprite and Source classes but it's not
  # really important enough to warrant the effort.
  #
  class Sprite
    attr_reader :name, :sources

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

    # Returns the y-position of a given source.
    #
    # @return [Integer]
    #   The vertical position of the source image.
    #
    def position_of(source)
      unless @sources.include?(source)
        raise MissingSource,
          "Source image '#{source}' is not present in the '#{@name}' sprite"
      end

      unless @positions
        # Rather than calculate each time we call position_of, cache the
        # position of each image the first time it is called. Since we almost
        # always want the position of each image at some point (when
        # generating CSS), it works out faster to fetch each source height
        # just once.
        @positions, offset = {}, 0
        @sources.each_with_index do |src, idx|
          @positions[src] = offset
          offset += images[idx].rows + 20
        end
      end

      @positions[source]
    end

    # Returns a digest which represents the sprite and it's contents. If any
    # of the file _contents_ or source names change, so will the hash.
    #
    # @return [Digest::SHA256]
    #
    def digest
      digests = @sources.inject([]) do |digests, source|
        digests << Digest::SHA256.hexdigest(source)
        digests << Digest::SHA256.file(paths[@sources.index(source)])
      end

      Digest::SHA256.hexdigest(digests.join)
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
            of the `#{@name}' sprite. Was looking in `#{@dir}'.
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
