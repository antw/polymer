require 'spec_helper'

describe Flexo::Source do
  subject { Flexo::Source }

  before(:each) do
    use_helper!
    write_source 'sprite_one/one', 20, 20
  end

  # --- image ----------------------------------------------------------------

  it { should have_public_method_defined(:image) }

  describe '#image' do
    it 'should return the Image instance path when the source file exists' do
      source = Flexo::Source.new(path_to_source('sprite_one/one'))
      source.image.should be_a(Magick::Image)
    end

    it 'should raise an error when the source file does not exist' do
      running = lambda {
        Flexo::Source.new(path_to_source('__invalid__')).image
      }

      running.should raise_error(Flexo::MissingSource,
        /Couldn't find the source file/)
    end
  end

  # --- digest ---------------------------------------------------------------

  it { should have_public_method_defined(:digest) }

  describe '#digest' do
    it 'should return a 64 character string' do
      digest = Flexo::Source.new(path_to_source('sprite_one/one')).digest
      digest.should be_a(String)
      digest.should have(64).characters
    end

    it 'should raise an error when the source file does not exist' do
      running = lambda {
        Flexo::Source.new(path_to_source('__invalid__')).digest
      }

      running.should raise_error(Flexo::MissingSource,
        /Couldn't find the source file/)
    end
  end

end
