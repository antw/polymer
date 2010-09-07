require 'rmagick'

module Flexo::Processors
  class RMagick

    # Creates a sprite image using RMagick for a given +sprite+.
    #
    # @param [Flexo::Sprite] sprite
    #   The Sprite for which an image is to be created.
    #
    def self.process(sprite)
      unless sprite.save_path.dirname.writable?
        raise Flexo::TargetNotWritable, <<-ERROR
          Flexo can't save the #{sprite.name} sprite in
          "#{sprite.save_path.dirname.to_s}" as it isn't writable.
        ERROR
      end

      list = Magick::ImageList.new

      sprite.sources.each do |source|
        list << source.image

        if sprite.padding and sprite.padding > 0
          list << Magick::Image.new(1, sprite.padding) do
            self.background_color = '#F000'
          end
        end
      end

      # RMagick uses instance_eval, @set isn't available in the block below.
      sources_length = sprite.sources.length

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
      montage.crop!(0, 0, 0, (montage.first.rows) - sprite.padding)
      montage.write("PNG32:#{sprite.save_path}")

      [ 'generated', sprite.name, :green ]
    end # self.process

  end
end # Flexo::Processors
