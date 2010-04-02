module Montage
  # Represents a single source file used in a sprite.
  #
  class Source

    attr_reader :name
    alias_method :to_s, :name

    # Creates a new Source instance.
    #
    # @param [Pathname] dir
    #   The directory in which the source image should stored.
    # @param [String] name
    #   The name of the source image, sans extension
    # @param [String] sprite
    #   The name of the sprite to which the source belongs. Used only in
    #   error messages.
    #
    def initialize(dir, name, sprite_name)
      @dir, @name, @sprite_name = dir, name, sprite_name
    end

    def inspect # :nodoc
      "#<Montage::Source #{@sprite_name}:#{@name}>"
    end

    # Returns the full path to the source image.
    #
    # @return [Pathname]
    # @raise  [Montage::MissingSource]
    #
    def path
      @path ||= begin
        unless @dir.directory?
          raise MissingSource, <<-MESSAGE.compress_lines
            Couldn't find the source directory for the `#{@sprite_name}'
            sprite. Montage was looking for #{@dir}; if your sprites are in a
            different location, add a 'config.sources' option your config
            file.
          MESSAGE
        end

        path = @dir.entries.detect do |entry|
          entry.to_s.chomp(entry.extname) == @name
        end

        if path.nil?
          raise MissingSource, <<-MESSAGE.compress_lines
            Couldn't find a matching file for source image `#{@name}' as part
            of the `#{@sprite_name}' sprite. Was looking in `#{@dir}'.
          MESSAGE
        end

        @dir + path
      end
    end

    # Returns the RMagick image instance representing the source.
    #
    # @return [Magick::Image]
    #
    def image
      @image ||= Magick::Image.read(path).first
    end

    # Returns a digest which represents the sprite name and file contents.
    #
    # @return [String]
    #
    def digest
      Digest::SHA256.hexdigest(@name + Digest::SHA256.file(path).to_s)
    end

  end # Source
end # Montage
