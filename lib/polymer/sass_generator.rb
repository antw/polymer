module Polymer
  class SassGenerator

    TEMPLATE = Pathname.new(__FILE__).dirname + 'templates/sass_mixins.erb'

    # Given a project, generates a Sass mixin stylesheet which can can be
    # included into your own Sass stylesheets.
    #
    # @param [Polymer::Project] project
    #   The project instance for which to generate a Sass stylesheet.
    #
    # @return [true]
    #   Returned when the stylesheet was generated and saved to the location
    #   specified by +project.sass+.
    # @return [false]
    #   Returned when +project.sass+ evaluates to false, disabling generation
    #   of the Sass mixin file.
    #
    def self.generate(project)
      return false unless project.sass

      if project.sass.to_s[-5..-1] == '.sass'
        project.sass.dirname.mkpath
        save_to = project.sass
      else
        project.sass.mkpath
        save_to = project.sass + '_polymer.sass'
      end

      # We need to keep track of any existing data URI values since, if the
      # sprite is unchanged, we won't have access to it.
      existing_data_uris = extract_existing_data_uris(
        save_to, project.data_uri_sprites)

      data_uris = project.data_uri_sprites.inject({}) do |memo, sprite|
        if sprite.save_path.file?
          data = [sprite.save_path.read].pack('m')

          # Ruby < 1.9 doesn't support pack('m0'),
          # so we have to do it manually.
          data.gsub!(/\n/, '')

          memo[sprite.name] = "data:image/png;base64,#{data}"
        else
          memo[sprite.name] = existing_data_uris[sprite.name]
        end

        memo
      end

      File.open(save_to, 'w') do |file|
        file.puts ERB.new(File.read(TEMPLATE), nil, '<>').result(binding)
      end

      true
    end # self.generate

    # Given a path to a Sass file, extracts the existing data URI strings.
    #
    def self.extract_existing_data_uris(path, sprites)
      return {} unless path.file?

      sass = path.read.split("\n")

      sprites.inject({}) do |memo, sprite|
        if index = sass.index(".#{sprite.name}_data")
          # The data is contained on the line following the selector.
          memo[sprite.name] = sass[index + 1].scan(/url\((.+)\)/).first.first
        end

        memo
      end
    end

  end # SassGenerator
end # Polymer
