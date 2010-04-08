require File.expand_path('../../spec_helper', __FILE__)

describe Montage::Project do
  subject { Montage::Project }

  # Class Methods ============================================================

  # --- find -----------------------------------------------------------------

  it { should respond_to(:find) }

  describe '.find' do
    describe 'when given a project root with montage.yml in the root' do
      before(:all) do
        @helper = Montage::Spec::ProjectHelper.new
        @helper.write_simple_config

        @project = Montage::Project.find(@helper.project_dir)
        @config  = @helper.path_to_file('montage.yml')
      end

      it_should_behave_like 'a project with correct paths'
    end # when given a project root with montage.yml in the root

    describe 'when given a project root with montage.yml in ./config' do
      before(:all) do
        @helper = Montage::Spec::ProjectHelper.new
        @helper.write_simple_config('config/montage.yml')

        @project = Montage::Project.find(@helper.project_dir)
        @config  = @helper.path_to_file('config/montage.yml')
      end

      it_should_behave_like 'a project with correct paths'
    end # when given a project root with montage.yml in ./config

    describe 'when given a project subdirectory' do
      before(:all) do
        @helper = Montage::Spec::ProjectHelper.new
        @helper.mkdir('sub/sub')
        @helper.write_simple_config

        @project = Montage::Project.find(@helper.project_dir + 'sub/sub')
        @config  = @helper.path_to_file('montage.yml')
      end

      it_should_behave_like 'a project with correct paths'
    end # when given a project subdirectory

    describe 'when given a configuration file in the root' do
      before(:all) do
        @helper = Montage::Spec::ProjectHelper.new
        @helper.write_simple_config

        @project = Montage::Project.find(@helper.path_to_file('montage.yml'))
        @config  = @helper.path_to_file('montage.yml')
      end

      it_should_behave_like 'a project with correct paths'
    end # when given a configuration file in the root

    describe 'when given a configuration file in ./config' do
      before(:all) do
        @helper = Montage::Spec::ProjectHelper.new
        @helper.write_simple_config('config/montage.yml')

        @project = Montage::Project.find(
          @helper.path_to_file('config/montage.yml'))

        @config  = @helper.path_to_file('config/montage.yml')
      end

      it_should_behave_like 'a project with correct paths'
    end # when given a configuration file in ./config

    describe 'when the config file specifies custom directories' do
      before(:all) do
        @helper = Montage::Spec::ProjectHelper.new
        @helper.write_config <<-CONFIG
        ---
          config.sources:    "custom/sources"
          config.sprites:    "custom/output"
          config.sass:       "custom/sass"
          config.sprite_url: "custom/images"

          sprite_one:
            - source_one
        CONFIG

        @project = Montage::Project.find(@helper.project_dir)
        @config  = @helper.path_to_file('montage.yml')
        @base    = @helper.path_to_file('custom')
      end

      it 'should set the sources path' do
        @project.paths.sources.should == @base + 'sources'
      end

      it 'should set the sprites path' do
        @project.paths.sprites.should == @base + 'output'
      end

      it 'should set the SASS output path' do
        @project.paths.sass.should == @base + 'sass'
      end
    end

    describe 'when the config file specifies a custom root' do
      before(:all) do
        @helper = Montage::Spec::ProjectHelper.new
        @helper.write_config 'settings/sprites.yml', <<-CONFIG
        ---
          config.root: "../custom_root"

          sprite_one:
            - source_one
        CONFIG

        @project = Montage::Project.find(
          @helper.path_to_file('settings/sprites.yml'))

        @config  = @helper.path_to_file('settings/sprites.yml')
        @root    = @helper.path_to_file('custom_root')
      end

      it_should_behave_like 'a project with correct paths'
    end

    describe 'when the config file specifies a custom absolute root' do
      before(:all) do
        @helper = Montage::Spec::ProjectHelper.new
        @helper.write_config 'settings/sprites.yml', <<-CONFIG
        ---
          config.root: "#{@helper.path_to_file('custom_root')}"

          sprite_one:
            - source_one
        CONFIG

        @project = Montage::Project.find(
          @helper.path_to_file('settings/sprites.yml'))

        @config  = @helper.path_to_file('settings/sprites.yml')
        @root    = @helper.path_to_file('custom_root')
      end

      it_should_behave_like 'a project with correct paths'
    end

    describe 'when the config file specifies not to generate Sass' do
      before(:all) do
        @helper = Montage::Spec::ProjectHelper.new
        @helper.write_config <<-CONFIG
        ---
          config.sass: false
        CONFIG
      end

      it 'should set the SASS output path to false' do
        @helper.project.paths.sass.should be_false
      end
    end

    describe 'when given an empty directory' do
      before(:all) do
        @helper = Montage::Spec::ProjectHelper.new
      end

      it 'should raise an error' do
        running = lambda { Montage::Project.find(@helper.project_dir) }
        running.should raise_exception(Montage::MissingProject)
      end
    end # when given an empty directory

    describe 'when given an invalid path' do
      it 'should raise an error' do
        running = lambda { Montage::Project.find('__invalid__') }
        running.should raise_exception(Montage::MissingProject)
      end
    end # when given an invalid path
  end

  # Instance Methods =========================================================

  it { should have_public_method_defined(:paths) }

  # --- sprites --------------------------------------------------------------

  it { should have_public_method_defined(:sprites) }

  describe '#sprites' do
    context "when the project has one sprite with two sources" do
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

      it 'should return an array with one element' do
        @helper.project.sprites.should have(1).sprite
      end

      it 'should have two sources in the sprite' do
        @helper.project.sprites.first.should have(2).sources
      end
    end # when the project has one sprite with two sources

    context "when the project has two sprites with 2/1 sources" do
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

      it 'should return an array with two elements' do
        @helper.project.sprites.should have(2).sprite
      end

      it 'should have two sources in the first sprite' do
        @helper.project.sprite('sprite_one').should have(2).sources
      end

      it 'should have one source in the second sprite' do
        @helper.project.sprite('sprite_two').should have(1).sources
      end
    end # when the project has one sprite with two sources

  end

end
