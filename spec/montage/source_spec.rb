require File.expand_path('../../spec_helper', __FILE__)

describe Montage::Source do
  subject { Montage::Source }

  # --- path -----------------------------------------------------------------

  it { should have_public_method_defined(:path) }

  describe '#path' do
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
    end

    it 'should return the path when the source file exists' do
      name = @helper.project.sprites.first.sources.first.name

      source = Montage::Source.new(@helper.project.paths.sources, name, 'nm')
      source.path.should == @helper.project.paths.sources + "#{name}.png"
    end

    it 'should raise an error when the source file does not exist' do
      running = lambda {
        Montage::Source.new(
          @helper.project.paths.sources, '__invalid__', 'nm').path
      }

      running.should raise_error(Montage::MissingSource,
        /Couldn't find a matching file/)
    end

    it 'should raise an error when the source directory does not exist' do
      name = @helper.project.sprites.first.sources.first.name

      running = lambda {
        Montage::Source.new(Pathname.new('__invalid__'), name, 'nm').path
      }

      running.should raise_error(Montage::MissingSource,
        /Couldn't find the source directory/)
    end
  end

end
