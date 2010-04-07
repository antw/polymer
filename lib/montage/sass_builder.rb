module Montage
  # Given a project, builds a SASS file containing mixin to simplify use of
  # the generated sprites in a project.
  #
  class SassBuilder

    TEMPLATE = Pathname.new(__FILE__).dirname + 'templates/sass_mixins.erb'

    # Creates a new SassBuilder instance.
    #
    # @param [Montage::Project] project
    #   The project whose Sass file is to be built.
    #
    def initialize(project)
      @project = project
    end

    # Builds the Sass mixin file, then writes it to disk.
    #
    # @return [Boolean]
    #
    def write
      if @project.paths.sass.to_s[-5..-1] == '.sass'
        @project.paths.sass.dirname.mkpath
        save_to = @project.paths.sass
      else
        @project.paths.sass.mkpath
        save_to = @project.paths.sass + '_montage.sass'
      end

      File.open(save_to, 'w') do |file|
        file.puts ERB.new(File.read(TEMPLATE), nil, '<>').result(binding)
      end
    end

  end # SassBuilder
end
