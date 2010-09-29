require 'spec_helper'

describe Polymer::SassGenerator do
  subject { Polymer::SassGenerator }

  # --- generate -------------------------------------------------------------

  it { should respond_to(:generate) }

  describe '.generate' do
    before(:each) do
      use_helper!
    end

    context 'with default settings, one sprite and two sources' do
      before(:each) do
        write_source 'fry/one'
        write_source 'fry/two'

        @result = Polymer::SassGenerator.generate(project)

        @sass = path_to_file('public/stylesheets/sass/_polymer.sass')
      end

      it_should_behave_like 'a Sass generator'

      it 'should include conditionals for each sprite' do
        contents = @sass.read
        contents.should include('if $source == "fry/one"')
        contents.should include('if $source == "fry/two"')
      end

      describe 'the generated mixins' do
        it 'should correctly position the first source' do
          sass_to_css(@sass, 'polymer("fry/one")').should \
            include('background: url(/images/fry.png) 0px 0px no-repeat')

          sass_to_css(@sass, 'polymer-position("fry/one")').should \
            include('background-position: 0px 0px')
        end

        it 'should correctly position the second source' do
          sass_to_css(@sass, 'polymer("fry/two")').should \
            include('background: url(/images/fry.png) 0px -40px no-repeat')

          sass_to_css(@sass, 'polymer-position("fry/two")').should \
            include('background-position: 0px -40px')
        end

        it 'should apply x-offsets' do
          sass_to_css(@sass, 'polymer("fry/one", 5px)').should \
            include('background: url(/images/fry.png) 5px 0px no-repeat')

          sass_to_css(@sass, 'polymer-position("fry/one", 5px)').should \
            include('background-position: 5px 0px')
        end

        it 'should apply y-offsets' do
          # -20px (source one) - 20px (padding) - 10px (third arg) = -50px
          sass_to_css(@sass, 'polymer("fry/two", 0px, -10px)').should \
            include('background: url(/images/fry.png) 0px -50px no-repeat')

          sass_to_css(@sass, 'polymer-position("fry/two", 0px, -10px)').should \
            include('background-position: 0px -50px')
        end
      end # the generated mixins
    end # with default settings, one sprite and two sources

    context 'with default settings and two sprites' do
      before(:each) do
        write_source 'fry/one'
        write_source 'leela/one'

        @result = Polymer::SassGenerator.generate(project)

        @sass = path_to_file('public/stylesheets/sass/_polymer.sass')
      end

      it_should_behave_like 'a Sass generator'

      it 'should include conditionals for each sprite' do
        contents = @sass.read
        contents.should include('if $source == "fry/one"')
        contents.should include('if $source == "leela/one"')
      end

      describe 'the generated mixins' do
        it 'should correctly style sources in the first sprite' do
          sass_to_css(@sass, 'polymer("fry/one")').should \
            include('background: url(/images/fry.png) 0px 0px no-repeat')

          sass_to_css(@sass, 'polymer-position("fry/one")').should \
            include('background-position: 0px 0px')
        end

        it 'should correctly style sources in the second sprite' do
          sass_to_css(@sass, 'polymer("leela/one")').should \
            include('background: url(/images/leela.png) 0px 0px no-repeat')

          sass_to_css(@sass, 'polymer-position("leela/one")').should \
            include('background-position: 0px 0px')
        end
      end # the generated mixins
    end # with default settings and two sprites

    context 'with custom Sass directory path' do
      before(:each) do
        write_config <<-CONFIG
          config.sass "public/sass"

          sprites "sources/:name/*" => 'sprites/:name.png'
        CONFIG

        write_source 'fry/one'

        @result = Polymer::SassGenerator.generate(project)
        @sass = path_to_file('public/sass/_polymer.sass')
      end

      it_should_behave_like 'a Sass generator'

    end # with a custom Sass directory path

    context 'with a custom Sass file path' do
      before(:each) do
        write_config <<-CONFIG
          config.sass "public/sass/_here.sass"

          sprites "sources/:name/*" => "sprites/:name.png"
        CONFIG

        write_source 'fry/one'

        @result = Polymer::SassGenerator.generate(project)
        @sass = path_to_file('public/sass/_here.sass')
      end

      it_should_behave_like 'a Sass generator'

    end # with a custom Sass file path

    context 'with a custom URL setting' do
      before(:each) do
        write_config <<-CONFIG
          config.url "/right/here/:name.png"

          sprites "sources/:name/*" => "sprites/:name.png"
        CONFIG

        write_source 'fry/one'

        @result = Polymer::SassGenerator.generate(project)
        @sass = path_to_file('public/stylesheets/sass/_polymer.sass')
      end

      it_should_behave_like 'a Sass generator'

      it 'should set the correct image URL' do
        sass_to_css(@sass, 'polymer("fry/one")').should \
          include("url(/right/here/fry.png)")
      end
    end # with a custom URL setting

    context 'with Sass disabled' do
      before(:each) do
        write_config <<-CONFIG
          config.sass false

          sprites "sources/:name/*" => "sprites/:name.png"
        CONFIG
      end

      it 'should return false' do
        Polymer::SassGenerator.generate(project).should be_false
      end
    end # with Sass disabled

  end # .generate

end
