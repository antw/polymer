require 'spec_helper'

describe Flexo::SpriteDefinition do
  subject { Flexo::SpriteDefinition }

  # --------------------------------------------------------------------------

  before(:each) do
    @helper = Flexo::Spec::ProjectHelper.new
    @helper.write_simple_config
  end

  # --------------------------------------------------------------------------

  context 'with src/*, matching two sources' do
    before(:each) do
      @helper.touch('src/big', 'src/small')

      definition = Flexo::SpriteDefinition.new(
        @helper.project, 'src/*', 'name' => 'lurrr', "to" => "_")

      @return = definition.to_sprites
    end

    it 'should return a single sprite' do
      @return.length.should == 1
    end

    it 'should set the sprite name' do
      @return.first.name.should == 'lurrr'
    end

    it 'should have two sources' do
      @return.first.should have(2).sources

      sources = @return.first.sources

      sources.detect { |source| source.name == 'small' }.should be
      sources.detect { |source| source.name == 'big' }.should be
    end

    it 'should set the sprite save path' do
      @return.first.save_path.should == @helper.path_to_file('_')
    end

    it 'should set the padding to 20' do
      @return.first.padding.should == 20
    end

    it 'should set the url' do
      @return.first.url.should == '/images/lurrr.png'
    end
  end

  # --------------------------------------------------------------------------

  context 'with src/:name/*, matching two sprites with two sources each' do
    before(:each) do
      @helper.touch('src/big/one', 'src/small/one')

      definition = Flexo::SpriteDefinition.new(
        @helper.project, 'src/:name/*', "to" => ":name")

      @return = definition.to_sprites
    end

    it 'should return two sprites' do
      @return.length.should == 2
      @return.detect { |sprite| sprite.name == 'small' }.should be
      @return.detect { |sprite| sprite.name == 'big' }.should be
    end

    it 'should have one source in each sprite' do
      @return.each { |sprite| sprite.should have(1).sources }
    end

    it 'should set the sprite save paths' do
      @return.each do |sprite|
        sprite.save_path.should == @helper.path_to_file(sprite.name)
      end
    end

    it 'should set the padding to 20' do
      @return.each { |sprite| sprite.padding == 20 }
    end

    it 'should set the sprite urls' do
      @return.each do |sprite|
        sprite.url.should == "/images/#{sprite.name}.png"
      end
    end
  end

  # --------------------------------------------------------------------------

  context 'with **/:name/*, matching two sprites with two sources each' do
    before(:each) do
      @helper.touch 'base/one/big/one',
                    'base/two/big/two',
                    'base/one/small/three',
                    'base/two/small/four'

      definition = Flexo::SpriteDefinition.new(
        @helper.project, '**/:name/*', "to" => ":name")

      @return = definition.to_sprites
    end

    it 'should return two sprites' do
      @return.length.should == 2
      @return.detect { |sprite| sprite.name == 'small' }.should be
      @return.detect { |sprite| sprite.name == 'big' }.should be
    end

    it 'should have two sources in each sprite' do
      @return.each { |sprite| sprite.should have(2).sources }
    end

    it 'should set the sprite save paths' do
      @return.each do |sprite|
        sprite.save_path.should == @helper.path_to_file(sprite.name)
      end
    end

    it 'should set the padding to 20' do
      @return.each { |sprite| sprite.padding == 20 }
    end

    it 'should set the sprite urls' do
      @return.each do |sprite|
        sprite.url.should == "/images/#{sprite.name}.png"
      end
    end
  end

  # --------------------------------------------------------------------------

  context 'with src/:name/*.{png,jpg}, matching one sprite with two sources' do
    before(:each) do
      @helper.touch 'src/sprite/one.png',
                    'src/sprite/two.jpg',
                    'src/sprite/three.app', # non-match
                    'src/sprite/four'       # non-match

      definition = Flexo::SpriteDefinition.new(
        @helper.project, 'src/:name/*.{png,jpg}', "to" => ":name")

      @return = definition.to_sprites
    end

    it 'should return a single sprite' do
      @return.length.should == 1
    end

    it 'should have two sources' do
      @return.first.should have(2).sources

      sources = @return.first.sources

      sources.detect { |source| source.name == 'one' }.should be
      sources.detect { |source| source.name == 'two' }.should be
    end

    it 'should set the sprite save path' do
      @return.first.save_path.should == @helper.path_to_file('sprite')
    end

    it 'should set the padding to 20' do
      @return.first.padding.should == 20
    end

    it 'should set the url' do
      @return.first.url.should == '/images/sprite.png'
    end
  end

  # --------------------------------------------------------------------------

  context 'with (absolute)/src/:name/*, matching two sprites with one source each' do
    before(:each) do
      @helper.touch('src/big/one', 'src/small/one')

      definition = Flexo::SpriteDefinition.new(
        @helper.project, @helper.project.paths.root + 'src/:name/*',
        "to" => ":name")

      @return = definition.to_sprites
    end

    it 'should return two sprites' do
      @return.length.should == 2
      @return.detect { |sprite| sprite.name == 'small' }.should be
      @return.detect { |sprite| sprite.name == 'big' }.should be
    end

    it 'should have one source in each sprite' do
      @return.each { |sprite| sprite.should have(1).sources }
    end

    it 'should set the sprite save paths' do
      @return.each do |sprite|
        sprite.save_path.should == @helper.path_to_file(sprite.name)
      end
    end

    it 'should set the padding to 20' do
      @return.each { |sprite| sprite.padding == 20 }
    end

    it 'should set the sprite urls' do
      @return.each do |sprite|
        sprite.url.should == "/images/#{sprite.name}.png"
      end
    end
  end

  # --------------------------------------------------------------------------

  context 'with a custom padding option set to 50' do
    before(:each) do
      @helper.touch('src/big/one')

      definition = Flexo::SpriteDefinition.new(
        @helper.project, 'src/:name/*', 'padding' => 50)

      @return = definition.to_sprites
    end

    it 'should set the padding to 50' do
      @return.first.padding == 50
    end
  end

  # --------------------------------------------------------------------------

  context 'where the project customises the padding to 50' do
    before(:each) do
      @helper.touch('src/big/one')
      @helper.write_config <<-CONFIG
        ---
          config.padding: 50

          "public/images/sprites/:name/*.{png,jpg,jpeg,gif}":
            to: "public/images/:name.png"
      CONFIG

      definition = Flexo::SpriteDefinition.new(
        @helper.project, 'src/:name/*')

      @return = definition.to_sprites
    end

    it 'should set the padding to 50' do
      @return.first.padding == 50
    end
  end

  # --------------------------------------------------------------------------

  context 'with a custom url option set to /omicron_persei_8' do
    before(:each) do
      @helper.touch('src/big/one')

      definition = Flexo::SpriteDefinition.new(
        @helper.project, 'src/:name/*', 'url' => '/omicron_persei_8/:name')

      @return = definition.to_sprites
    end

    it 'should set the sprite url' do
      @return.first.url.should == '/omicron_persei_8/big'
    end
  end

  # --------------------------------------------------------------------------

  context 'with a custom url option using the :filename segment' do
    before(:each) do
      @helper.touch('src/big/one')

      definition = Flexo::SpriteDefinition.new(
        @helper.project, 'src/:name/*', 'url' => '/omicron_persei_8/:filename')

      @return = definition.to_sprites
    end

    it 'should set the sprite url' do
      @return.first.url.should == '/omicron_persei_8/big.png'
    end
  end

  # --------------------------------------------------------------------------

  context 'where the project customises the URL to /omicron_persei_8' do
    before(:each) do
      @helper.touch('src/big/one')
      @helper.write_config <<-CONFIG
        ---
          config.url: "/omicron_persei_8/:name"

          "public/images/sprites/:name/*.{png,jpg,jpeg,gif}":
            to: "public/images/:name.png"
      CONFIG

      definition = Flexo::SpriteDefinition.new(
        @helper.project, 'src/:name/*')

      @return = definition.to_sprites
    end

    it 'should set the sprite url' do
      @return.first.url.should == '/omicron_persei_8/big'
    end
  end

  # --------------------------------------------------------------------------

  context 'with a :name capture, and a "name" option' do
    it 'should raise an error' do
      running = lambda { @path = Flexo::SpriteDefinition.new(
        @helper.project, '/__invalid__/:name/*',
        'name' => 'lurrr', 'to' => ':name') }

      running.should raise_error(Flexo::DuplicateName)
    end
  end

  # --------------------------------------------------------------------------

  context 'with a :name capture, and no :name segment in the "to" option' do
    it 'should raise an error' do
      running = lambda { @path = Flexo::SpriteDefinition.new(
        @helper.project, '/:name/*', 'to' => '_') }

      running.should raise_error(Flexo::MissingName)
    end
  end

  # --------------------------------------------------------------------------

  context 'with a full file name, and no :name capture or option' do
    it 'should infer the sprite name from the filename' do
      @helper.touch('src/source')

      definition = Flexo::SpriteDefinition.new(
        @helper.project, 'src/*', 'to' => 'lurrr.png')

      @return = definition.to_sprites

      @return.length.should == 1
      @return[0].name.should == 'lurrr'
    end
  end

  # --------------------------------------------------------------------------

  context 'with no "to" option' do
    it 'should set a default' do
      @sprite = Flexo::SpriteDefinition.new(@helper.project, '_',
        'name' => 'lurrr').to_sprites.first

      @sprite.save_path.should_not be_nil
    end
  end

end
