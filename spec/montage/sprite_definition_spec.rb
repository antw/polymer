require File.expand_path('../../spec_helper', __FILE__)

describe Montage::SourcePath do
  subject { Montage::SourcePath }

  it { should have_public_method_defined(:sprite_names) }

  # --------------------------------------------------------------------------

  context 'with no :name segment' do
    before(:all) do
      @helper = Montage::Spec::ProjectHelper.new
      @helper.touch('src/big')
      @helper.touch('src/small')

      @path = Montage::SourcePath.new(@helper.path_to_file('src/*'))
    end

    it 'should return nil to sprite_names' do
      @path.sprite_names.should be_nil
    end

    describe 'matching_sources' do
      it 'should return a hash with a single key' do
        @path.matching_sources.keys.should == [nil]
      end

      it 'should contain the files' do
        @path.matching_sources[nil].should == [
          @helper.path_to_file('src/big'), @helper.path_to_file('src/small')]
      end
    end
  end

  # --------------------------------------------------------------------------

  context 'with a :name segment, matching "big" and "small" directories' do
    before(:all) do
      @helper = Montage::Spec::ProjectHelper.new
      @helper.touch('src/big/one')
      @helper.touch('src/small/one')

      @path = Montage::SourcePath.new(@helper.path_to_file('src/:name/*'))
    end

    it 'should return the sprite_names' do
      @path.sprite_names.length.should == 2
      @path.sprite_names.should include('big')
      @path.sprite_names.should include('small')
    end

    describe 'matching_sources' do
      it 'should return a hash with a two keys' do
        @path.matching_sources.keys.length.should == 2
        @path.matching_sources.keys.should include('big')
        @path.matching_sources.keys.should include('small')
      end

      it 'should contain the files' do
        @path.matching_sources['big'].should == [
          @helper.path_to_file('src/big/one')]

        @path.matching_sources['small'].should == [
          @helper.path_to_file('src/small/one')]
      end
    end
  end

  # --------------------------------------------------------------------------

  context 'with a :name segment, and a greedy glob' do
    before(:all) do
      @helper = Montage::Spec::ProjectHelper.new
      @helper.touch('base/one/big/one')
      @helper.touch('base/two/big/two')
      @helper.touch('base/one/small/three')
      @helper.touch('base/two/small/four')

      @path = Montage::SourcePath.new(
        @helper.path_to_file('**/:name/*'))
    end

    it 'should return the sprite_names' do
      @path.sprite_names.length.should == 2
      @path.sprite_names.should include('big')
      @path.sprite_names.should include('small')
    end

    describe 'matching_sources' do
      it 'should return a hash with a two keys' do
        @path.matching_sources.keys.length.should == 2
        @path.matching_sources.keys.should include('big')
        @path.matching_sources.keys.should include('small')
      end

      it 'should contain the files' do
        @path.matching_sources['big'].should == [
          @helper.path_to_file('base/one/big/one'),
          @helper.path_to_file('base/two/big/two')]

        @path.matching_sources['small'].should == [
          @helper.path_to_file('base/one/small/three'),
          @helper.path_to_file('base/two/small/four')]
      end
    end
  end

  # --------------------------------------------------------------------------

  context 'with a :name segment, and an OR glob' do
    # I have no idea what one of these is called... :|
    before(:all) do
      @helper = Montage::Spec::ProjectHelper.new
      @helper.touch('src/sprite/one.png')
      @helper.touch('src/sprite/two.jpg')
      @helper.touch('src/sprite/three.app')
      @helper.touch('src/sprite/four')

      @path = Montage::SourcePath.new(
        @helper.path_to_file('src/:name/*.{png,jpg,}'))
    end

    it 'should return the sprite_names' do
      @path.sprite_names.should == ['sprite']
    end

    describe 'matching_sources' do
      it 'should return a hash with a one key' do
        @path.matching_sources.keys.length.should == 1
      end

      it 'should contain the files' do
        @path.matching_sources['sprite'].should == [
          @helper.path_to_file('src/sprite/one.png'),
          @helper.path_to_file('src/sprite/two.jpg')]
      end
    end
  end

end
