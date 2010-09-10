require 'rmagick'

module Flexo::Processors
  class RMagick

    # Creates a sprite image using RMagick for a given +sprite+.
    #
    # @param [Flexo::Sprite] sprite
    #   The Sprite for which an image is to be created.
    #
    def self.process(sprite)
      sprite.save
    end # self.process

    # Formats a say_status message.
    def self.format_after_message(sprite, *)
      [ 'generated', sprite.name, :green ]
    end

  end
end # Flexo::Processors
