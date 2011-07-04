module Polymer
  # Represents a collection of images which will be used to make a sprite.
  #
  class Sprite
    attr_reader   :name, :url, :padding, :sources
    attr_accessor :save_path

    # Creates a new Sprite instance.
    #
    # @param [String] name
    #   The name of the sprite.
    # @param [Array<Pathname>] sources
    #   An array of Pathname instances to be used as sources.
    # @param [Pathname, Symbol] save_path
    #   The location at which the sprite should be saved. When being used with
    #   a Project, this may instead be :data_uri; adding the sprite to the
    #   project will set the correct path.
    # @param [Integer] padding
    #   The amount of transparent space, in pixels, to be inserted between
    #   each source image.
    # @param [String] url
    #   The URL at which the sprite can be requested by a browser.
    #
    def initialize(name, sources, save_path, padding, url)
      @name      = name
      @sources   = sources.map { |path| Source.new(path) }
      @save_path = save_path
      @padding   = padding
      @url       = url
    end

    # @return [Polymer::Source]
    #   Returns the source whose name matches +name+.
    # @return [nil]
    #   Returns nil if no source with +name+ exists.
    #
    def source(name)
      sources.detect { |source| source.name == name }
    end

    # Returns the y-position of a given source.
    #
    # @param [String, Polymer::Source] name
    #   The name of the source whose position is to be returned, or the
    #   Polymer::Source instance itself.
    #
    # @return [Integer]
    #   The vertical position of the source image.
    # @return [nil]
    #   nil is returned if no sprite identified by +name+ exists.
    #
    def position_of(name)
      name = name.name if name.is_a?(Polymer::Source)

      unless self.source(name)
        raise MissingSource,
          "Source image `#{name}' is not present in the `#{@name}' sprite"
      end

      unless @positions
        # Rather than calculate each time we call position_of, cache the
        # position of each image the first time it is called. Since we almost
        # always want the position of each image at some point (when
        # generating CSS), it works out faster to fetch each source height
        # just once.
        @positions = {}
        @sources.inject(0) do |offset, src|
          @positions[src.name] = offset
          offset + src.image.height + @padding
        end
      end

      @positions[name]
    end

    # Returns a digest which represents the sprite and it's contents. If any
    # of the file _contents_ or source names change, so will the hash.
    #
    # @return [Digest::SHA256]
    #
    def digest
      Digest::SHA256.hexdigest(sources.map { |source| source.digest }.join)
    end

    # A sprite is equal to another sprite if the names are the same.
    #
    # @return [Boolean]
    #
    def ==(other)
      other.respond_to?(:name) and other.name == name
    end

    # Saves the composited sprite to disk.
    #
    # In the event that the sprite has no sources, +save+ will return false
    # and the existing file will be left untouched.
    #
    # @return [Boolean]
    #
    def save
      return false if @sources.empty?

      @save_path.dirname.mkpath

      unless @save_path.dirname.writable?
        raise Polymer::TargetNotWritable, <<-ERROR
          Polymer can't save the #{@name} sprite in
          `#{@save_path.dirname.to_s}' as it isn't writable.
        ERROR
      end

      width, height = @sources.inject([1, 0]) do |dimensions, source|
        # Determine the width of the sprite by finding the widest source.
        source_width = source.image.width
        dimensions[0] = source_width if source_width > dimensions[0]

        # Determine the height of the sprite by summing the height of each
        # source.
        dimensions[1] += source.image.height

        dimensions
      end

      if @padding and @padding > 0
        # Adjust the height to account for padding.
        height += (@sources.length - 1) * @padding
      end

      canvas = ChunkyPNG::Canvas.new(width, height)

      # Add each source to the canvas.
      @sources.each do |source|
        canvas.compose!(source.image, 0, position_of(source))
      end

      canvas.save(@save_path, :best_compression)

      true
    end

  end # Sprite
end # Polymer
