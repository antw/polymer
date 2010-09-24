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

      File.open(save_to, 'w') do |file|
        file.puts ERB.new(File.read(TEMPLATE), nil, '<>').result(binding)
      end

      true
    end # self.generate

  end # SassGenerator
end # Polymer
