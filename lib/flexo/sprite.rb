module Flexo
  # Represents a collection of images which will be used to make a sprite.
  #
  class Sprite
    attr_reader :name, :save_path, :url, :padding, :sources

    # Creates a new Sprite instance.
    #
    # @param [String] name
    #   The name of the sprite. Will be used as the sprite filename (with an
    #   extension added).
    # @param [Array(String, Pathname)] sources
    #   The name of each source image.
    # @param [Pathname] save_path
    #   The location at which the sprite should be saved.
    # @param [Flexo::Project] project
    #   The project to which the sprite belongs.
    # @param [Hash] options
    #   Extra options where you wish to override project defaults.
    #
    def initialize(name, sources, save_path, project, options = {})
      @name      = name
      @save_path = save_path

      @padding   = options.fetch(:padding, project.padding)
      @url       = options.fetch(:url, project.paths.url)

      @sources   = sources.map { |path| Source.new(path) }
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
      source = source.name if source.is_a?(Flexo::Source)

      unless sources.detect { |src| src.name == source }
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
        @sources.inject(0) do |offset, src|
          @positions[src.name] = offset
          offset + src.image.rows + @padding
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

    # Saves the composited sprite to disk.
    #
    # In the event that the sprite has no sources, +save+ will return false
    # and the existing file will be left untouched.
    #
    # @return [Boolean]
    #
    def save
      unless @save_path.dirname.writable?
        raise Flexo::TargetNotWritable, <<-ERROR
          Flexo can't save the #{@name} sprite in "#{@save_path.dirname.to_s}"
          as it isn't writable.
        ERROR
      end

      list = Magick::ImageList.new

      @sources.each do |source|
        list << source.image

        if @padding and @padding > 0
          list << Magick::Image.new(1, @padding) do
            self.background_color = '#F000'
          end
        end
      end

      # RMagick uses instance_eval, @set isn't available in the block below.
      sources_length = @sources.length

      montage = list.montage do
        self.gravity = Magick::NorthWestGravity
        # Transparent background.
        self.background_color = '#FFF0'
        # Allow each image to take up as much space as it needs.
        self.geometry = '+0+0'
        # columns=1, rows=Sources plus padding.
        self.tile = Magick::Geometry.new(1, sources_length * 2)
      end

      # Remove the blank space from the bottom of the image.
      montage.crop!(0, 0, 0, (montage.first.rows) - @padding)
      montage.write("PNG32:#{@save_path}")

      true
    end

  end # Sprite
end # Flexo
