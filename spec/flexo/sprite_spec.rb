require 'spec_helper'

describe Flexo::Sprite do
  subject { Flexo::Sprite }

  # --- initialization -------------------------------------------------------

  describe 'when initialized' do
    before(:all) do
      @helper = Flexo::Spec::ProjectHelper.new
      @helper.write_simple_config
    end

    it 'should set the name' do
      sprite = Flexo::Sprite.new('wheee', [], '_', @helper.project)
      sprite.name.should == 'wheee'
    end

    it 'should set the padding' do
      sprite = Flexo::Sprite.new('_', [], '_', @helper.project)
      sprite.padding.should == @helper.project.padding
    end

    it 'should set the save_path' do
      sprite = Flexo::Sprite.new('_', [],
        @helper.path_to_file('bye'), @helper.project)

      sprite.save_path.should == @helper.path_to_file('bye')
    end

    it 'should set the url' do
      sprite = Flexo::Sprite.new('_', [], '_', @helper.project)
      sprite.url.should == @helper.project.paths.url
    end

    describe 'with custom options' do
      before(:all) do
        @sprite = Flexo::Sprite.new('wheee', [], '_', @helper.project,
          :padding => 50, :url => '/omicron_persei_8')
      end

      it 'should set the custom padding' do
        @sprite.padding.should == 50
      end

      it 'should set the url' do
        @sprite.url.should == '/omicron_persei_8'
      end
    end
  end

  # --- images ---------------------------------------------------------------

  it { should have_public_method_defined(:images) }

  describe '#images' do
    before(:each) do
      @helper = Flexo::Spec::ProjectHelper.new
      @helper.write_simple_config

      @helper.write_source('sprite_one/one', 100, 25)
      @helper.write_source('sprite_one/two', 100, 25)

      @sprite = @helper.project.sprite('sprite_one')
    end

    describe 'when the sprite contains no sources' do
      before(:each) do
        @sprite = Flexo::Sprite.new('sprite', [], 'path', @helper.project)
      end

      it 'should return an array' do
        @sprite.images.should be_kind_of(Array)
      end

      it 'should be empty' do
        @sprite.images.should be_empty
      end
    end

    describe 'when the sprite contains two sources' do
      it 'should return an array' do
        @sprite.images.should be_kind_of(Array)
        @sprite.images.should have(2).images
      end

      it 'should contain Magick::Image instances' do
        @sprite.images.each { |i| i.should be_kind_of(Magick::Image) }
      end
    end
  end

  # --- position_of ----------------------------------------------------------

  it { should have_public_method_defined(:position_of) }

  describe '#position_of' do
    before(:each) do
      @helper = Flexo::Spec::ProjectHelper.new
      @helper.write_simple_config

      @helper.write_source('sprite_one/one', 100, 25)
      @helper.write_source('sprite_one/two', 100, 25)

      @sprite = @helper.project.sprite('sprite_one')
    end

    it 'should raise a MissingSource when the given source is not present' do
      running = lambda { @sprite.position_of('__invalid__') }
      running.should raise_error(Flexo::MissingSource,
        /'__invalid__' is not present in the 'sprite_one' sprite/)
    end

    it 'should return an integer' do
      @sprite.position_of('one').should == 0
    end

    it 'should account for the padding' do
      # 25px source, plus 20px padding
      @sprite.position_of('two').should == 45
    end

    it 'should accept a Source instance' do
      @sprite.position_of(@sprite.sources.first).should == 0
    end
  end

  # --- digest ---------------------------------------------------------------

  it { should have_public_method_defined(:digest) }

  describe '#digest' do
    before(:each) do
      @helper = Flexo::Spec::ProjectHelper.new
      @helper.write_simple_config

      @helper.write_source('sprite_one/one',   100, 25)
      @helper.write_source('sprite_one/two',   100, 25)
      @helper.write_source('sprite_two/three', 100, 25)
    end

    it 'should return a string' do
      @helper.project.sprites.first.digest.should be_a(String)
    end

    context 'when changing the image for a source' do
      before(:each) do
        @sprite_one_digest = @helper.project.sprite('sprite_one').digest
        @sprite_two_digest = @helper.project.sprite('sprite_two').digest
        @helper.write_source('sprite_one/one', 100, 30)
      end

      it 'should return something different when it is affected' do
        @helper.project.sprite('sprite_one').digest.should_not ==
          @sprite_one_digest
      end

      it 'should return the same value when unaffected' do
        @helper.project.sprite('sprite_two').digest.should ==
          @sprite_two_digest
      end
    end # when changing the image for a source
  end

end
