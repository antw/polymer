require 'spec_helper'

describe Flexo::Sprite do
  subject { Flexo::Sprite }

  before(:each) { use_helper! }

  # --- initialization -------------------------------------------------------

  describe 'when initialized' do
    before(:all) do
      @sprite = Flexo::Sprite.new('<name>', [], '<save_path>', 0, '<url>')
    end

    it 'should set the name' do
      @sprite.name.should == '<name>'
    end

    it 'should set the padding' do
      @sprite.padding.should == 0
    end

    it 'should set the save_path' do
      @sprite.save_path.should == '<save_path>'
    end

    it 'should set the url' do
      @sprite.url.should == '<url>'
    end

    it 'should set the sources' do
      @sprite.sources.should == []
    end
  end

  # --- source ---------------------------------------------------------------

  it { should have_public_method_defined(:source) }

  describe '#source' do
    before(:each) do
      write_source 'sprite_one/one', 100, 25
      write_source 'sprite_one/two', 100, 25

      @sprite = project.sprite('sprite_one')
    end

    it 'should return nil when no such source exists' do
      @sprite.source('invalid').should be_nil
    end

    it 'should return the source' do
      @sprite.source('one').should be_a(Flexo::Source)
    end
  end

  # --- position_of ----------------------------------------------------------

  it { should have_public_method_defined(:position_of) }

  describe '#position_of' do
    before(:each) do
      write_source 'sprite_one/one', 100, 25
      write_source 'sprite_one/two', 100, 25

      @sprite = project.sprite('sprite_one')
    end

    it 'should raise a MissingSource when the given source is not present' do
      running = lambda { @sprite.position_of('__invalid__') }
      running.should raise_error(Flexo::MissingSource,
        /`__invalid__' is not present in the `sprite_one' sprite/)
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
      write_source 'sprite_one/one',   100, 25
      write_source 'sprite_one/two',   100, 25
      write_source 'sprite_two/three', 100, 25
    end

    it 'should return a string' do
      project.sprites.first.digest.should be_a(String)
    end

    context 'when changing the image for a source' do
      before(:each) do
        @sprite_one_digest = project.sprite('sprite_one').digest
        @sprite_two_digest = project.sprite('sprite_two').digest

        write_source 'sprite_one/one', 100, 30
      end

      it 'should return something different when it is affected' do
        project.sprite('sprite_one').digest.should_not == @sprite_one_digest
      end

      it 'should return the same value when unaffected' do
        project.sprite('sprite_two').digest.should == @sprite_two_digest
      end
    end # when changing the image for a source
  end

  # --- save -----------------------------------------------------------------

  it { should have_public_method_defined(:save) }

  # tested in the generate sprite features

end
