require 'spec_helper'

describe Flexo::SassGenerator do
  subject { Flexo::SassGenerator }

  # --- generate -------------------------------------------------------------

  it { should respond_to(:generate) }

  describe '.generate' do
    before(:each) do
      @helper = Flexo::Spec::ProjectHelper.go!
    end

    context 'with default settings, one sprite and two sources' do
      before(:each) do
        @helper.write_source('fry/one')
        @helper.write_source('fry/two')

        @result = Flexo::SassGenerator.generate(@helper.project)

        @sass = @helper.path_to_file('public/stylesheets/sass/_flexo.sass')
      end

      it_should_behave_like 'a Sass generator'

      it 'should include conditionals for each sprite' do
        contents = @sass.read
        contents.should include('if $source == "fry/one"')
        contents.should include('if $source == "fry/two"')
      end

      describe 'the generated mixins' do
        it 'should correctly position the first source' do
          sass_to_css(@sass, 'flexo("fry/one")').should \
            include('background: url(/images/fry.png) 0px 0px no-repeat')

          sass_to_css(@sass, 'flexo-pos("fry/one")').should \
            include('background-position: 0px 0px')
        end

        it 'should correctly position the second source' do
          sass_to_css(@sass, 'flexo("fry/two")').should \
            include('background: url(/images/fry.png) 0px -40px no-repeat')

          sass_to_css(@sass, 'flexo-pos("fry/two")').should \
            include('background-position: 0px -40px')
        end

        it 'should apply x-offsets' do
          sass_to_css(@sass, 'flexo("fry/one", 5px)').should \
            include('background: url(/images/fry.png) 5px 0px no-repeat')

          sass_to_css(@sass, 'flexo-pos("fry/one", 5px)').should \
            include('background-position: 5px 0px')
        end

        it 'should apply y-offsets' do
          # -20px (source one) - 20px (padding) - 10px (third arg) = -50px
          sass_to_css(@sass, 'flexo("fry/two", 0px, -10px)').should \
            include('background: url(/images/fry.png) 0px -50px no-repeat')

          sass_to_css(@sass, 'flexo-pos("fry/two", 0px, -10px)').should \
            include('background-position: 0px -50px')
        end
      end # the generated mixins
    end # with default settings, one sprite and two sources

    context 'with default settings and two sprites' do
      before(:each) do
        @helper.write_source('fry/one')
        @helper.write_source('leela/one')

        @result = Flexo::SassGenerator.generate(@helper.project)

        @sass = @helper.path_to_file('public/stylesheets/sass/_flexo.sass')
      end

      it_should_behave_like 'a Sass generator'

      it 'should include conditionals for each sprite' do
        contents = @sass.read
        contents.should include('if $source == "fry/one"')
        contents.should include('if $source == "leela/one"')
      end

      describe 'the generated mixins' do
        it 'should correctly style sources in the first sprite' do
          sass_to_css(@sass, 'flexo("fry/one")').should \
            include('background: url(/images/fry.png) 0px 0px no-repeat')

          sass_to_css(@sass, 'flexo-pos("fry/one")').should \
            include('background-position: 0px 0px')
        end

        it 'should correctly style sources in the second sprite' do
          sass_to_css(@sass, 'flexo("leela/one")').should \
            include('background: url(/images/leela.png) 0px 0px no-repeat')

          sass_to_css(@sass, 'flexo-pos("leela/one")').should \
            include('background-position: 0px 0px')
        end
      end # the generated mixins
    end # with default settings and two sprites

    context 'with custom Sass directory path' do
      before(:each) do
        @helper.write_config <<-CONFIG
          config.sass "public/sass"

          sprites "public/images/sprites/:name/*" =>
            'public/images/:name.png'
        CONFIG

        @helper.write_source('fry/one')
        @result = Flexo::SassGenerator.generate(@helper.project)
        @sass = @helper.path_to_file('public/sass/_flexo.sass')
      end

      it_should_behave_like 'a Sass generator'

    end # with a custom Sass directory path

    context 'with a custom Sass file path' do
      before(:each) do
        @helper.write_config <<-CONFIG
          config.sass "public/sass/_here.sass"

          sprites "public/images/sprites/:name/*" =>
            "public/images/:name.png"
        CONFIG

        @helper.write_source('fry/one')
        @result = Flexo::SassGenerator.generate(@helper.project)
        @sass = @helper.path_to_file('public/sass/_here.sass')
      end

      it_should_behave_like 'a Sass generator'

    end # with a custom Sass file path

    context 'with a custom URL setting' do
      before(:each) do
        @helper.write_config <<-CONFIG
          config.url "/right/here/:name.png"

          sprites "public/images/sprites/:name/*" =>
            "public/images/:name.png"
        CONFIG

        @helper.write_source('fry/one')
        @result = Flexo::SassGenerator.generate(@helper.project)
        @sass = @helper.path_to_file('public/stylesheets/sass/_flexo.sass')
      end

      it_should_behave_like 'a Sass generator'

      it 'should set the correct image URL' do
        sass_to_css(@sass, 'flexo("fry/one")').should \
          include("url(/right/here/fry.png)")
      end
    end # with a custom URL setting

    context 'with Sass disabled' do
      before(:each) do
        @helper.write_config <<-CONFIG
          config.sass false

          sprites "public/images/sprites/:name/*" =>
            "public/images/:name.png"
        CONFIG
      end

      it 'should return false' do
        Flexo::SassGenerator.generate(@helper.project).should be_false
      end
    end # with Sass disabled

  end # .generate

end
