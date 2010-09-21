require 'spec_helper'

describe Flexo::Source do
  subject { Flexo::Source }

  # --- image ----------------------------------------------------------------

  it { should have_public_method_defined(:image) }

  describe '#image' do
    before(:each) do
      @helper = Flexo::Spec::ProjectHelper.go!
      @helper.write_source('sprite_one/one', 100, 25)
    end

    it 'should return the Image instance path when the source file exists' do
      source = Flexo::Source.new(@helper.path_to_source('sprite_one/one'))
      source.image.should be_a(Magick::Image)
    end

    it 'should raise an error when the source file does not exist' do
      running = lambda {
        Flexo::Source.new(@helper.path_to_source('__invalid__')).image
      }

      running.should raise_error(Flexo::MissingSource,
        /Couldn't find the source file/)
    end
  end

end
