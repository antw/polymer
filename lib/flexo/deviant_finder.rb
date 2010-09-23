module Flexo
  # Given a Sprite, DeviantFinder checks to see if the sprite has any sources
  # which are significantly wider than the average.
  class DeviantFinder

    # Given a Sprite, checks to see if the sprite has any sources which are
    # significantly wider than the average. Images with a small standard
    # deviation in source width or fewer than 3 sources will be skipped.
    #
    # @param [Flexo::Sprite] sprite
    #   The sprite whose source widths are to be checked.
    #
    # @return [Array<String>]
    #   Returns an array of source images whose width is greater than the
    #   standard deviation.
    # @return [nil]
    #   Returns nil if all of the source images are an approriate width.
    #
    def self.find_deviants(sprite)
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
    def self.format_ui_message(sprite, deviants)
      if deviants
        <<-MESSAGE.compress_lines
          Your "#{sprite.name}" sprite contains one or more source images
          which deviate significantly from the average source width. You might
          want to consider removing these sources from the sprite in order to
          reduce the sprite filesize.

          Wide sources: #{deviants.map(&:name).join(', ')}
        MESSAGE
      end
    end

    private # ----------------------------------------------------------------

    # Knuth.
    #
    # @param [Array<Integer>] data
    #   An array containing the widths of each source image.
    #
    # @return [Array<Integer, Integer>]
    #   Returns a two-element array whose first element is the mean width of
    #   the source images; the second element is the standard deviation.
    #
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

  end # DeviantFinder
end # Flexo
