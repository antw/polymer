module Flexo
  # Represents a single source file used in a sprite.
  #
  class Source

    attr_reader :name, :path
    alias_method :to_s, :name

    # Creates a new Source instance.
    #
    # @param [Pathname] path
    #   The path the the source image.
    #
    def initialize(path)
      @path = Pathname.new(path)
      @name = @path.basename.to_s.chomp(@path.extname.to_s)
    end

    def inspect # :nodoc
      "#<Flexo::Source #{@name}>"
    end

    # Returns the RMagick image instance representing the source.
    #
    # @return [Magick::Image]
    #
    def image
      raise MissingSource, "Couldn't find the source file `#{@path}'" \
        unless @path.file?

      @image ||= Magick::Image.read(@path).first
    end

    # Returns a digest which represents the sprite name and file contents.
    #
    # @return [String]
    #
    def digest
      raise MissingSource, "Couldn't find the source file `#{@path}'" \
        unless @path.file?

      Digest::SHA256.hexdigest(@name + Digest::SHA256.file(@path).to_s)
    end

  end # Source
end # Flexo
