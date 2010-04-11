require File.expand_path('../../spec_helper', __FILE__)

describe Montage::Source do
  subject { Montage::Source }

  # --- image -----------------------------------------------------------------

  it { should have_public_method_defined(:image) }

  describe '#image' do
    before(:each) do
      @helper = Montage::Spec::ProjectHelper.new
      @helper.write_config <<-CONFIG
      ---
        sprite_one:
          - one.png
      CONFIG

      @helper.write_source('one', 100, 25)
    end

    it 'should return the Image instance path when the source file exists' do
      source = Montage::Source.new(@helper.path_to_source('one'))
      source.image.should be_a(Magick::Image)
    end

    it 'should raise an error when the source file does not exist' do
      running = lambda {
        Montage::Source.new(@helper.path_to_source('__invalid__')).image
      }

      running.should raise_error(Montage::MissingSource,
        /Couldn't find the source file/)
    end
  end

end
