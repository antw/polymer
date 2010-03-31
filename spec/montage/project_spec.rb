require File.expand_path('../../spec_helper', __FILE__)

describe Montage::Project do
  subject { Montage::Project }

  # Class Methods ============================================================

  it { should respond_to(:find) }
  it { should respond_to(:init) }

  #
  # .find
  #

  describe '.find' do
    describe 'when given a project root with montage.yml in the root' do
      before(:all) do
        @project = Montage::Project.find(fixture_path(:root_config))
        @root    = Pathname.new(fixture_path(:root_config))
        @config  = Pathname.new(fixture_path(:root_config, 'montage.yml'))
      end

      it_should_behave_like 'a project with correct paths'
    end # when given a project root with montage.yml in the root

    describe 'when given a project root with montage.yml in ./config' do
      before(:all) do
        @project = Montage::Project.find(fixture_path(:directory_config))
        @root    = Pathname.new(fixture_path(:directory_config))
        @config  = Pathname.new(
          fixture_path(:directory_config, 'config/montage.yml'))
      end

      it_should_behave_like 'a project with correct paths'
    end # when given a project root with montage.yml in ./config

    describe 'when given a project subdirectory' do
      before(:all) do
        @project = Montage::Project.find(fixture_path(:subdirs, 'sub/sub'))
        @root    = Pathname.new(fixture_path(:subdirs))
        @config  = Pathname.new(fixture_path(:subdirs, 'montage.yml'))
      end

      it_should_behave_like 'a project with correct paths'
    end # when given a project subdirectory

    describe 'when given a configuration file in the root' do
      before(:all) do
        @project = Montage::Project.find(
          fixture_path(:root_config, 'montage.yml'))

        @root    = Pathname.new(fixture_path(:root_config))
        @config  = Pathname.new(fixture_path(:root_config, 'montage.yml'))
      end

      it_should_behave_like 'a project with correct paths'
    end # when given a configuration file in the root

    describe 'when given a configuration file in ./config' do
      before(:all) do
        @project = Montage::Project.find(
          fixture_path(:directory_config, 'config/montage.yml'))
        @root    = Pathname.new(fixture_path(:directory_config))
        @config  = Pathname.new(
          fixture_path(:directory_config, 'config/montage.yml'))
      end

      it_should_behave_like 'a project with correct paths'
    end # when given a configuration file in ./config

    describe 'when the config file specifies custom directories' do
      before(:all) do
        @project = Montage::Project.find(fixture_path(:custom_dirs))
        @base = Pathname.new(fixture_path(:custom_dirs)) + 'custom'
      end

      it 'should set the sources path' do
        @project.paths.sources.should == @base + 'sources'
      end

      it 'should set the sprites path' do
        @project.paths.sprites.should == @base + 'output'
      end

      it 'should set the CSS output path' do
        @project.paths.css.should == @base + 'css'
      end

      it 'should set the SASS output path' do
        @project.paths.sass.should == @base + 'sass'
      end

      it 'should set the CSS sprite URL' do
        @project.paths.url.should == 'custom/images'
      end
    end

    describe 'when given an empty directory' do
      it 'should raise an error' do
        running = lambda { Montage::Project.find(fixture_path(:empty)) }
        running.should raise_exception(Montage::MissingProject)
      end
    end # when given an empty directory

    describe 'when given an invalid path' do
      it 'should raise an error' do
        running = lambda { Montage::Project.find('__invalid__') }
        running.should raise_exception(Montage::MissingProject)
      end
    end # when given an invalid path
  end # .find

  # .init

  describe '.init' do
    describe 'with only a directory' do
      it 'should save the montage.yml file in the project root' do
        Dir.mktmpdir do |root|
          Montage::Project.init(root)
          File.file?(File.join(root, 'montage.yml')).should be_true
        end
      end

      it 'should not create a config directory' do
        Dir.mktmpdir do |root|
          Montage::Project.init(root)
          File.directory?(File.join(root, 'config')).should be_false
        end
      end
    end # when creating a new Montage project

    describe 'with a directory containing a ./config subdirectory' do
      it 'should save the montage.yml file in ./config' do
        Dir.mktmpdir do |root|
          Dir.mkdir(File.join(root, 'config'))
          Montage::Project.init(root)
          File.file?(File.join(root, 'config', 'montage.yml')).should be_true
        end
      end

      it 'should not save a montage.yml file in the project root' do
        Dir.mktmpdir do |root|
          Dir.mkdir(File.join(root, 'config'))
          Montage::Project.init(root)
          File.file?(File.join(root, 'montage.yml')).should be_false
        end
      end
    end # with a directory containing a ./config subdirectory

    describe 'when the given path is not writeable' do
      it 'should raise an error' do
        Dir.mktmpdir do |root|
          lambda do
            Montage::Project.init(File.join(root, '__invalid__'))
          end.should raise_error(/no such file or directory/i)
        end
      end
    end # when the given path is not writeable

    describe 'when montage.yml already exists at the project root' do
      it 'should raise an error' do
        running = lambda { Montage::Project.init(fixture_path(:root_config)) }
        running.should raise_error(Montage::ProjectExists,
          Regexp.new(Regexp.escape(fixture_path(:root_config))))
      end
    end # when montage.yml already exists at the project root

    describe 'when montage.yml already exists in ./config' do
      it 'should raise an error' do
        running = lambda { Montage::Project.init(fixture_path(:directory_config)) }
        running.should raise_error(Montage::ProjectExists,
          Regexp.new(Regexp.escape(fixture_path(:directory_config))))
      end
    end # when montage.yml already exists in ./config
  end # .init

  # Instance Methods =========================================================

  it { should have_public_method_defined(:paths) }

end
