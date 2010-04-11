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
  class SpriteDefinition
    # Creates a new SpriteDefinition instance.
    #
    # @param [Montage::Project]       project
    # @param [String, Pathname]       path
    # @param [Hash{String => Object}] options
    #
    def initialize(project, path, options = {})
      @project = project
      @path    = project.paths.root + path

      # Symbolize option keys.
      @options = options.inject({}) do |opts, (key, value)|
        opts[key.to_sym] = value ; opts
      end

      @options[:to] = (@project.paths.root +
                      (@options[:to] || Project::DEFAULTS[:to])).to_s

      @options[:url]     ||= project.paths.url
      @options[:padding] ||= project.padding

      if has_name_segment? and @options.has_key?(:name)
        raise Montage::DuplicateName, <<-ERROR.compress_lines
          Sprite `#{path}' has both a :name path segment and a "name"
          option; please use only one.
        ERROR
      elsif not has_name_segment? and not @options.has_key?(:name)
        raise Montage::MissingName, <<-ERROR.compress_lines
          Sprite `#{path}' requires a name. Add a :name path segment
          or add a "name" option.
        ERROR
      elsif has_name_segment? and not @options[:to] =~ /:name/
        raise Montage::MissingName, <<-ERROR.compress_lines
          Sprite `#{path}' requires :name in the "to" option.
        ERROR
      end
    end

    # Returns an array of Sprites defined.
    #
    # @return [Array(Montage::Sprite)]
    #
    def to_sprites
      matching_sources.map do |sprite_name, sources|
        save_path = Pathname.new(@options[:to].gsub(/:name/, sprite_name))

        url = @options[:url].dup # Since it may be the DEFAULT string
        url.gsub!(/:name/, sprite_name)
        url.gsub!(/:filename/, save_path.basename.to_s)

        Montage::Sprite.new(sprite_name, sources, save_path, @project,
          :url     => url,
          :padding => @options[:padding]
        )
      end
    end

    private # ================================================================

    # Returns whether the path has a :name segment.
    #
    # @return [Boolean]
    #
    def has_name_segment?
      @path.to_s =~ /:name/
    end

    # Returns a Hash containing source files which can be used when creating
    # Sprites. Each key is sprite name with each value the path to a matching
    # source file. When a SpriteDefinition doesn't have a :name segment, the
    # Hash will contain a single key: nil.
    #
    # @return[Hash{String => Array(Pathname)}]
    #
    def matching_sources
      @matching_sources ||= begin
        if not has_name_segment?
          { @options[:name] => Pathname.glob(@path.to_s) }
        else
          regexp = Regexp.escape(@path.to_s)
          regexp.gsub!(/\\\*\\\*/, '.+')
          regexp.gsub!(/\\\*/,     '[^\\/]+')
          regexp.gsub!(/:name/,    '([^\\/]+)')

          # Replace OR globs ({png,jpg,etc}).
          regexp.gsub!(/\\\{([^\\\}]+)\\\}/) do |found|
            "(?:#{found[2..-4].split(',').join('|')})"
          end

          all_files = Pathname.glob(@path.to_s.gsub(/:name/, '*'))
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

  end # SpriteDefinition
end # Montage
