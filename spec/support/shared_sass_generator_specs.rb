shared_examples_for 'a Sass generator' do
  # Requires
  #
  # @sass   => A Pathname to a Sass/SCSS stylesheet.
  # @result => The result of calling .generator
  #
  it 'should return true' do
    @result.should be_true
  end

  it 'should save the Sass file' do
    @sass.should be_file
  end
end

module Flexo::Spec
  module Sass
    # Creates CSS using a given Sass file.
    #
    # @param [Pathname] import
    #   Path to the Flexo Sass file which should be imported.
    # @param [String] inc
    #   String representing an include declaration which should be applied
    #   to the CSS selector.
    #
    def sass_to_css(import, inc)
      ::Sass::Engine.new(<<-SASS.gsub(/^ {8}/, '')).render
        @import #{import.realpath}

        .rule
          @include #{inc}
      SASS
    end
  end # Sass
end # Flexo::Spec
