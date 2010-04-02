module Montage
  # Represents a collection of images which will be used to make a sprite.
  #
  class Sprite
    attr_reader :name

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
      @name, @dir = name, dir

      @sources =
        sources.inject(ActiveSupport::OrderedHash.new) do |hash, source|
          hash[source] = Source.new(@dir, source, @name) ; hash
        end
    end

    # Returns an array of Source instances held by this Sprite.
    #
    # @return [Array<Source>]
    #
    def sources
      @sources.map { |_, source| source }
    end

    # Returns an array of RMagick image instances; one for each source.
    #
    # @return [Array<Magick::Image>]
    #   The Image instances for the sources.
    #
    def images
      sources.map { |source| source.image }
    end

    # Returns the y-position of a given source.
    #
    # @return [Integer, Source]
    #   The vertical position of the source image.
    #
    def position_of(source)
      source = source.name if source.is_a?(Source)

      unless @sources.keys.include?(source)
        raise MissingSource,
          "Source image '#{source}' is not present in the '#{@name}' sprite"
      end

      unless @positions
        # Rather than calculate each time we call position_of, cache the
        # position of each image the first time it is called. Since we almost
        # always want the position of each image at some point (when
        # generating CSS), it works out faster to fetch each source height
        # just once.
        @positions = {}
        @sources.inject(0) do |offset, (name, src)|
          @positions[name] = offset
          offset + src.image.rows + 20
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
      Digest::SHA256.hexdigest(sources.map { |source| source.digest }.join)
    end

  end # Set
end # Montage
