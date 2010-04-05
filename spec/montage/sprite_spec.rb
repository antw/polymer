require File.expand_path('../../spec_helper', __FILE__)

describe Montage::Sprite do
  subject { Montage::Sprite }

  # --- images ---------------------------------------------------------------

  it { should have_public_method_defined(:images) }

  describe '#images' do
    before(:each) do
      @helper = Montage::Spec::ProjectHelper.new
      @helper.write_config <<-CONFIG
      ---
        sprite_one:
          - one
          - two
      CONFIG

      @helper.write_source('one', 100, 25)
      @helper.write_source('two', 100, 25)

      @sprite = @helper.project.sprite('sprite_one')
    end

    describe 'when the sprite contains no sources' do
      before(:each) do
        @sprite = Montage::Sprite.new('sprite', [],
          @helper.project.paths.sources)
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
      @helper = Montage::Spec::ProjectHelper.new
      @helper.write_config <<-CONFIG
      ---
        sprite_one:
          - one
          - two
      CONFIG

      @helper.write_source('one', 100, 25)
      @helper.write_source('two', 100, 25)

      @sprite = @helper.project.sprite('sprite_one')
    end

    it 'should raise a MissingSource when the given source is not present' do
      running = lambda { @sprite.position_of('__invalid__') }
      running.should raise_error(Montage::MissingSource,
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
      @helper = Montage::Spec::ProjectHelper.new
      @helper.write_config <<-CONFIG
      ---
        sprite_one:
          - one
          - two

        sprite_two:
          - three
      CONFIG

      @helper.write_source('one',   100, 25)
      @helper.write_source('two',   100, 25)
      @helper.write_source('three', 100, 25)
    end

    it 'should return a string' do
      @helper.project.sprites.first.digest.should be_a(String)
    end

    context 'when changing the source order for a sprite' do
      before(:each) do
        @sprite_one_digest = @helper.project.sprite('sprite_one').digest
        @sprite_two_digest = @helper.project.sprite('sprite_two').digest
        @helper.write_config <<-CONFIG
        ---
          sprite_one:
            - two
            - one

          sprite_two:
            - three
        CONFIG
      end

      it 'should return something different when it is affected' do
        @helper.project.sprite('sprite_one').digest.should_not ==
          @sprite_one_digest
      end

      it 'should return the same value when unaffected' do
        @helper.project.sprite('sprite_two').digest.should ==
          @sprite_two_digest
      end
    end # when changing the source order for a sprite

    context 'when changing the image for a source' do
      before(:each) do
        @sprite_one_digest = @helper.project.sprite('sprite_one').digest
        @sprite_two_digest = @helper.project.sprite('sprite_two').digest
        @helper.write_source('one', 100, 30)
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

  # --- write ----------------------------------------------------------------

  it { should have_public_method_defined(:write) }

  describe '#write' do
    before(:each) do
      @helper = Montage::Spec::ProjectHelper.new
      @helper.write_source('one', 100, 25)
      @helper.write_source('two', 100, 25)
      @helper.write_config <<-CONFIG
        ---
          sprite_one:
            - one
            - two
      CONFIG

      @sprite = @helper.project.sprite('sprite_one')
      @dir    = @helper.project.paths.sprites
      @output = @dir + "#{@sprite.name}.png"
    end

    it 'should raise an error if the target is not writeable' do
      old_mode = @dir.stat.mode
      @dir.chmod(555)

      begin
        running = lambda { @sprite.write }
        running.should raise_error(Montage::TargetNotWritable)
      ensure
        @dir.chmod(old_mode)
      end
    end

    context 'when the sprite contains two sources, at 100x25px each' do
      it_should_behave_like 'saving a sprite'

      it 'should be 100 pixels wide' do
        @sprite.write
        Magick::Image.ping(@output).first.columns.should == 100
      end

      it 'should be 70 pixels tall' do
        @sprite.write
        Magick::Image.ping(@output).first.rows.should == 70
      end
    end

    context 'when the sprite contains two sources, at 20x20px and 100x100' do
      before(:each) do
        @helper.write_source('one',  20,  20)
        @helper.write_source('two', 100, 100)
      end

      it_should_behave_like 'saving a sprite'

      it 'should be 100 pixels wide' do
        @sprite.write
        Magick::Image.ping(@output).first.columns.should == 100
      end

      it 'should be 140 pixels tall' do
        @sprite.write
        Magick::Image.ping(@output).first.rows.should == 140
      end
    end

    context 'when the sprite contains two sources, at 100x25px each, and ' \
            'the project uses 50px padding' do
      before(:each) do
        @helper.write_config <<-CONFIG
          ---
            config.padding: 50

            sprite_one:
              - one
              - two

            sprite_two:
              - three
        CONFIG
        @sprite = @helper.project.sprite('sprite_one')
      end

      it_should_behave_like 'saving a sprite'

      it 'should be 100 pixels wide' do
        @sprite.write
        Magick::Image.ping(@output).first.columns.should == 100
      end

      it 'should be 100 pixels tall' do
        @sprite.write
        Magick::Image.ping(@output).first.rows.should == 100
      end
    end
  end

end
