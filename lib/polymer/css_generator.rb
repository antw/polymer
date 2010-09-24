module Polymer
  class CSSGenerator

    # --- Class Methods ------------------------------------------------------

    # Returns a string which may be used as the background statement for the
    # given sprite and source pair.
    #
    # @param [Polymer::Sprite] sprite
    # @param [Polymer::Source] source
    #
    # @return [String]
    #
    def self.background_statement(sprite, source)
      "background: url(#{sprite.url}) 0 " \
      "#{-sprite.position_of(source)}px no-repeat;"
    end

    # Returns a string which may be used as the background-position statement
    # for the given sprite and source pair.
    #
    # @param [Polymer::Sprite] sprite
    # @param [Polymer::Source] source
    #
    # @return [String]
    #
    def self.position_statement(sprite, source)
      "background-position: 0 #{-sprite.position_of(source)}px;"
    end

  end # CSSGenerator
end # Polymer
