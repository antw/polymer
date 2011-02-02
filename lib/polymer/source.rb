module Polymer
  # Represents a single source file used in a sprite.
  #
  class Source

    # @return [String] The sprite name; the filename sans-extension.
    attr_reader :name

    # @return [Pathname] The path to the source file on disk.
    attr_reader :path

    # Creates a new Source instance.
    #
    # @param [Pathname] path
    #   The path the the source image.
    #
    def initialize(path)
      @path = Pathname.new(path)
      @name = @path.basename(@path.extname).to_s
    end

    # Returns the Image instance representing the source.
    #
    # @return [ChunkyPNG::Image]
    #
    def image
      assert_file!
      @image ||= ChunkyPNG::Image.from_file(@path)
    end

    # Returns a digest which represents the sprite name and file contents.
    #
    # @return [String]
    #
    def digest
      assert_file!
      Digest::SHA256.hexdigest(@name + Digest::SHA256.file(@path).to_s)
    end

    #######
    private
    #######

    # Checks that the source file exists and is a file.
    #
    # @raise [Polymer::MissingSource]
    #   Raised if the source file is not present, or is not a file.
    #
    def assert_file!
      raise MissingSource,
        "Couldn't find the source file `#{@path}'" unless @path.file?
    end

  end # Source
end # Polymer
