require 'spec_helper'

describe Polymer::Optimisation, :optimisation => true do
  subject { Polymer::Optimisation }

  fixtures = Pathname.new(File.expand_path('../../fixtures', __FILE__))
  UNOPTIMISED_PNG = fixtures + 'unoptimised.png'
  OPTIMISED_PNG   = fixtures + 'optimised.png'

  it { should respond_to(:optimisers) }
  it { should respond_to(:optimise_file)  }

  # Make the fixture images available.
  before(:each) do
    @fixtures = Pathname.new(Dir.mktmpdir)
    @unoptimised_png = @fixtures + 'unoptimised.png'
    @optimised_png   = @fixtures + 'optimised.png'

    FileUtils.cp(UNOPTIMISED_PNG, @unoptimised_png)
    FileUtils.cp(OPTIMISED_PNG,   @optimised_png)
  end

  # Remove the temporary fixtures.
  after(:each) do
    FileUtils.remove_entry_secure(@fixtures)
  end

  describe '.optimise_file' do
    context 'when given an optimised image' do
      it 'should return 0' do
        Polymer::Optimisation.optimise_file(@optimised_png).should == 0
      end
    end # when given an optimised image

    context 'when given an unoptimised image' do
      it 'should return 0' do
        Polymer::Optimisation.optimise_file(@unoptimised_png).should >= 0
      end
    end # when given an optimised image
  end

  # === OPTIMSERS ============================================================

  [ Polymer::Optimisation::PNGOut,
    Polymer::Optimisation::OptiPNG,
    Polymer::Optimisation::PNGCrush ].each do |optimiser|

    describe optimiser.name.split('::').last do

      # Ensure that the optimiser is available.
      before(:all) do
        pending "#{optimiser.name} not available" unless optimiser.supported?
        @optimiser = optimiser.new
      end

      # ----------------------------------------------------------------------

      describe '#run' do
        context 'when given an optimised image' do
          it 'should return 0' do
            @optimiser.run(@optimised_png).should == 0
          end

          it 'should not leave any temporary file leftovers' do
            @optimiser.run(@optimised_png)
            Pathname.glob(@fixtures + '*.tmp').should be_empty
          end
        end # when given an optimised image

        context 'when given an unoptimised image' do
          it 'should return >0' do
            @optimiser.run(@unoptimised_png).should >= 0
          end

          it 'should not leave any temporary file leftovers' do
            @optimiser.run(@unoptimised_png)
            Pathname.glob(@fixtures + '*.tmp').should be_empty
          end
        end # when given an optimised image
      end # run

    end # descrbe optimiser

  end # each optimiser
end

