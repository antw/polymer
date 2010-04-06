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
    # @param [Project] Project
    #   The project to which the sprite belongs.
    #
    def initialize(name, sources, project)
      @name, @project = name, project

      @sources =
        sources.inject(ActiveSupport::OrderedHash.new) do |hash, source|
          hash[source] = Source.new(@project.paths.sources, source, @name)
          hash
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

    # Returns the path to the sprite on disk.
    #
    # @return [Pathname]
    #
    def path
      @project.paths.sprites + "#{@name}.png"
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

    # Uses RMagick to creates a 8-bit (with alpha) PNG containing all of the
    # source files.
    #
    # If a file exists at the output path, it will be overwritten.
    #
    # @raise [Montage::TargetNotWritable]
    #   Raised when the output directory can not be written to.
    #
    def write
      unless @project.paths.sprites.writable?
        raise TargetNotWritable, <<-MESSAGE
          Montage can't save the sprite in `#{@project.paths.sprites.to_s}'
          as it isn't writable.
        MESSAGE
      end

      list = sources.inject(Magick::ImageList.new) do |list, source|
        list << source.image
        list << Magick::Image.new(1, @project.padding) do
          self.background_color = '#FFF0'
        end
      end

      # RMagick uses instance_eval, @set isn't available in the block below.
      sources_length = sources.length

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
      montage.crop!(0, 0, 0, (montage.first.rows) - @project.padding)
      montage.write("PNG32:#{path}")
    end

  end # Set
end # Montage
