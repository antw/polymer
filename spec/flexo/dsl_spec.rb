require 'spec_helper'

describe Flexo::DSL do
  subject { Flexo::DSL }

  # --------------------------------------------------------------------------

  before(:each) do
    @helper = Flexo::Spec::ProjectHelper.new
    @helper.write_simple_config
  end

  # Builds a project using the DSL, with the helper directory as the root.
  def dsl(&block)
    Flexo::DSL.build(@helper.project_dir, &block)
  end

  # Builds a project using the DSL, and returns the sprites from the project.
  def dsl_sprites(&block)
    dsl(&block).sprites
  end

  # --- sprite ---------------------------------------------------------------

  it { should have_public_method_defined(:sprite)  }
  it { should have_public_method_defined(:sprites) }

  describe '#sprite' do

    context 'with src/*, matching two sources' do
      before(:each) do
        @helper.touch 'src/fry.png', 'src/leela.png'

        @sprites = dsl_sprites do
          sprite 'src/*' => 'lurrr.png'
        end

        @sprite = @sprites.first
      end

      it 'should create a single sprite' do
        @sprites.length.should == 1
      end

      it 'should set the sprite name' do
        @sprite.name.should == 'lurrr'
      end

      it 'should set two sources on the sprite' do
        @sprite.should have(2).sources

        sources = @sprite.sources

        sources.detect { |source| source.name == 'fry' }.should be
        sources.detect { |source| source.name == 'leela' }.should be
      end

      it 'should set the sprite save path' do
        @sprite.save_path.should == @helper.path_to_file('lurrr.png')
      end

      it 'should set the padding to 20' do
        @sprite.padding.should == 20
      end

      it 'should set the URL' do
        @sprite.url.should == '/images/lurrr.png'
      end
    end # with src/*, matching two sources

    # ------------------------------------------------------------------------

    context 'with src/:name/*, matching two sprites and one source each' do
      before(:each) do
        @helper.touch('src/lurrr/one', 'src/ndnd/one')

        @sprites = dsl_sprites do
          sprites 'src/:name/*' => ':name.png'
        end
      end

      it 'should create two sprites' do
        @sprites.length.should == 2
        @sprites.detect { |sprite| sprite.name == 'lurrr' }.should be
        @sprites.detect { |sprite| sprite.name == 'ndnd'  }.should be
      end

      it 'should have one source in each sprite' do
        @sprites.each { |sprite| sprite.should have(1).sources }
      end

      it 'should set the sprite save paths' do
        @sprites.each do |sprite|
          sprite.save_path.should ==
            @helper.path_to_file("#{sprite.name}.png")
        end
      end

      it 'should set the sprite URLs' do
        @sprites.each do |sprite|
          sprite.url.should == "/images/#{sprite.name}.png"
        end
      end
    end # with src/:name/*, matching two sprites and two sources each

    # ------------------------------------------------------------------------

    context 'with src/*.{png,jpg}, matching one sprite with two sources' do
      before(:each) do
        @helper.touch 'src/one.png',
                      'src/two.jpg',
                      'src/three.app', # non-match
                      'src/four'       # non-match

        @sprites = dsl_sprites do
          sprites 'src/*.{png,jpg}' => 'lurrr.png'
        end
      end

      it 'should create one sprite' do
        @sprites.length.should == 1
      end

      it 'should have two sources' do
        @sprites.first.should have(2).sources

        sources = @sprites.first.sources

        sources.detect { |source| source.name == 'one' }.should be
        sources.detect { |source| source.name == 'two' }.should be
      end
    end # with src/*.{png,jpg}, matching one sprite with two sources

    # ------------------------------------------------------------------------

    context 'with a custom padding option set to 50' do
      before(:each) do
        @helper.touch('src/lurrr')

        @sprites = dsl_sprites do
          sprite 'src/*' => 'lurrr.png', :padding => 50
        end
      end

      it 'should set the sprite padding to 50px' do
        @sprites.first.padding.should == 50
      end
    end # with a custom padding option set to 50

    # ------------------------------------------------------------------------

    context 'with two sprites, and a custom padding option set to 50' do
      before(:each) do
        @helper.touch('src/lurrr/one', 'src/ndnd/one')

        @sprites = dsl_sprites do
          sprite 'src/:name/*' => ':name.png', :padding => 50
        end
      end

      it 'should create two sprites' do
        @sprites.length.should == 2
      end

      it 'should set the sprite padding to 50px' do
        @sprites.first.padding.should == 50
        @sprites.last.padding.should  == 50
      end
    end # with two sprites, and a custom padding option set to 50

    # ------------------------------------------------------------------------

    context 'with a custom padding option set to false' do
      before(:each) do
        @helper.touch('src/lurrr')

        @sprites = dsl_sprites do
          sprite 'src/*' => 'lurrr.png', :padding => false
        end
      end

      it 'should set the sprite padding to 0px' do
        @sprites.first.padding.should == 0
      end
    end # with a custom padding option set to false

    # ------------------------------------------------------------------------

    context 'with a custom URL option set to /omicron_persei_8' do
      before(:each) do
        @helper.touch('src/lurrr')

        @sprites = dsl_sprites do
          sprite 'src/*' => 'lurrr.png', :url => '/omicron_persei_8'
        end
      end

      it 'should set the sprite URL' do
        @sprites.first.url.should == '/omicron_persei_8'
      end
    end # with a custom URL option set to /omicron_persei_8

    # ------------------------------------------------------------------------

    context 'with a custom URL option set to /omicron_persei_8/:filename' do
      before(:each) do
        @helper.touch('src/lurrr')

        @sprites = dsl_sprites do
          sprite 'src/*' => 'lurrr.png', :url => '/omicron_persei_8/:filename'
        end
      end

      it 'should set the sprite URL' do
        @sprites.first.url.should == '/omicron_persei_8/lurrr.png'
      end
    end # with a custom URL option set to /omicron_persei_8/:filename

    # ------------------------------------------------------------------------

    context 'with a sprite whose name has already been used' do
      it 'should raise an error' do
        @helper.touch 'src/fry/one.png'

        running = lambda do
          dsl do
            sprite 'src/:name/*' => '1/:name'
            sprite 'src/:name/*' => '2/:name'
          end
        end

        running.should raise_error(Flexo::DuplicateName)
      end
    end # with a sprite whose name has already been used

    # ------------------------------------------------------------------------

    context 'with a :name capture and no :name segment in the save path' do
      it 'should raise an error' do
        running = lambda { dsl { sprite 'src/:name/*' => '_' } }
        running.should raise_error(Flexo::MissingName)
      end
    end # with a :name capture and no :name segment in the save path

    # ------------------------------------------------------------------------

    context 'with a :name capture and :name option' do
      it 'should raise an error' do
        running = lambda { dsl { sprite 'src/:name/*' => '_', :name => '_' } }
        running.should raise_error(Flexo::DslError)
      end
    end # with a :name capture and a :name option

  end # #sprite

  # --- config ---------------------------------------------------------------

  it { should have_public_method_defined(:config)  }

  describe '#config' do

    before(:each) do
      @helper.touch 'src/fry.png'
    end

    # Sass

    describe 'sass' do
      before(:each) { pending 'Awaiting Sprite#sass' }

      it 'should default to /public/stylesheets/sass' do
        dsl {}.sass.should == '/public/stylesheets/sass'
      end

      it 'should set a custom value' do
        dsl { config.sass '/custom' }.sass.should == '/custom'
      end

      it 'should permit false' do
        dsl { config.sass false }.sass.should be_false
      end
    end

    # CSS

    describe 'css' do
      before(:each) { pending 'Awaiting Sprite#css' }

      it 'should default to false' do
        dsl {}.css.should be_false
      end

      it 'should set a custom value' do
        dsl { config.sass '/custom' }.css.should == '/custom'
      end
    end

    # Padding.

    describe 'padding' do
      it 'should default to 20' do
        sprites = dsl_sprites do
          sprite 'src/*' => '_'
        end

        sprites.first.padding.should == 20
      end

      it 'should cascade custom values to the sprites' do
        sprites = dsl_sprites do
          config.padding 50
          sprite 'src/*' => '_'
        end

        sprites.first.padding.should == 50
      end

      it 'should not cascade to sprites with custom values' do
        sprites = dsl_sprites do
          config.padding 50
          sprite 'src/*' => '_', :padding => 15
        end

        sprites.first.padding.should == 15
      end
    end

    # URL.

    describe 'url' do
      it 'should cascade custom values to the sprites' do
        sprites = dsl_sprites do
          config.url '/omicron_persei_8/:filename'
          sprite 'src/*' => 'lurrr.png'
        end

        sprites.first.url.should == '/omicron_persei_8/lurrr.png'
      end

      it 'should not cascade to sprites with custom values' do
        sprites = dsl_sprites do
          config.url '/omicron_persei_8'
          sprite 'src/*' => '_', :url => '/neutral_planet'
        end

        sprites.first.url.should == '/neutral_planet'
      end
    end

  end # #config

end
