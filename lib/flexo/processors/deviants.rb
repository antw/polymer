module Flexo::Processors
  # Given a Sprite, Deviants checks to see if the sprite has any sources which
  # are significantly wider than the average.
  class Deviants

    # Given a Sprite, checks to see if the sprite has any sources which are
    # significantly wider than the average. Images with a small standard
    # deviation in source width or fewer than 3 sources will be skipped.
    #
    # @param [Flexo::Sprite] sprite
    #   The sprite to be checked.
    #
    # @return [Array<String>, nil]
    #   Returns an array of source images whose width is greater than the
    #   standard deviation, or nil if all images are an appropriate width.
    #
    def self.process(sprite)
      # Need more than two sources to find deviants.
      return false if sprite.sources.size < 2

      mean, std_dev = standard_deviation(sprite.sources.map do |source|
        source.image.columns
      end)

      return false if std_dev < 100 # Skip images with a < 100px deviation.

      deviants = sprite.sources.select do |source|
        width = source.image.columns
        width > mean + std_dev || width < mean - std_dev
      end

      deviants.any? and deviants
    end

    # Print a warning if the sprite contains wide sources.
    def self.format_after_message(sprite, deviants)
      if deviants
        <<-MESSAGE.compress_lines
          Your "#{sprite.name}" sprite contains one or more source images
          which deviate significantly from the average source width. You might
          want to consider removing these sources from the sprite in order to
          reduce the sprite filesize.

          Wide sources: #{deviants.join(', ')}
        MESSAGE
      end
    end

    private # ----------------------------------------------------------------

    # Knuth.
    def self.standard_deviation(data)
      n, mean, m2 = 0, 0, 0

      data.each do |x|
        n = n + 1
        delta = x - mean
        mean = mean + delta / n
        m2 = m2 + delta * (x - mean)
      end

      [ mean, Math.sqrt(m2 / (n - 1)) ]
    end

  end # Deviants
end # Flexo::Processors
