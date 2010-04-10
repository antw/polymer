module Montage
  # Represents a pseudo-file system path, where a directory can be replaced
  # with the :sprite named segment. :name will match any directory -- all
  # files with the same :name value will be placed into the same sprite file.
  #
  # Where a sprite source defines a :name segment, no sprite name needs to be
  # explicitly set in the .montage file.
  #
  # For example, given the following directory structure:
  #
  #   /path/to/something/
  #     big/
  #       one.png
  #       two.png
  #     small/
  #       three.png
  #       four.png
  #
  # ... then segmented path "/path/to/something/:name/*" will match all four
  # PNG files, with "one" and "two" being placed in the "big" sprite, "three"
  # and "four" in the "small" sprite.
  #
  class SourcePath
    # Creates a new SourcePath instance.
    #
    # @param [String, Pathname] path
    #
    def initialize(path)
      @raw = Pathname.new(path)
    end

    # Returns whether the path has a :name segment.
    #
    # @return [Boolean]
    #
    def has_name_segment?
      @raw.to_s =~ /:name/
    end

    # Returns a Hash containing source files which can be used when creating
    # Sprites. Each key is sprite name with each value the path to a matching
    # source file. When a SourcePath doesn't have a :name segment, the Hash
    # will contain a single key: nil.
    #
    # @return[Hash{String => Array(Pathname)}]
    #
    def matching_sources
      @matching_sources ||= begin
        if not has_name_segment?
          { nil => Pathname.glob(@raw.to_s) }
        else
          regexp = Regexp.escape(@raw.to_s)
          regexp.gsub!(/\\\*\\\*/, '.+')
          regexp.gsub!(/\\\*/,     '[^\\/]+')
          regexp.gsub!(/:name/,    '([^\\/]+)')

          # Replace OR globs ({png,jpg,etc}).
          regexp.gsub!(/\\\{([^\\\}]+)\\\}/) do |found|
            "(?:#{found[2..-4].split(',').join('|')})"
          end

          all_files = Pathname.glob(@raw.to_s.gsub(/:name/, '*'))
          all_files.inject({}) do |sources, file|
            if file.file? && match = file.to_s.match(regexp)
              sources[match[1]] ||= []
              sources[match[1]] << file
            end

            sources
          end
        end
      end # begin
    end # matching_sources

    # Returns the name of each sprite which this SourcePath will match. In the
    # event that the instance contains no :name segment, +sprite_names+
    # returns nil.
    #
    # @return [Array(String), nil]
    #
    def sprite_names
      has_name_segment? and matching_sources.keys
    end

  end # SourcePath
end # Montage
