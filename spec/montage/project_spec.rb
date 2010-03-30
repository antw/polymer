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
      end

      it 'should set the project root path' do
        @project.paths.root.should ==
          Pathname.new(fixture_path(:root_config))
      end

      it 'should set the configuration file path' do
        @project.paths.config.should ==
          Pathname.new(fixture_path(:root_config, 'montage.yml'))
      end
    end # when given a project root with montage.yml in the root

    describe 'when given a project root with montage.yml in ./config' do
      before(:all) do
        @project = Montage::Project.find(fixture_path(:directory_config))
      end

      it 'should set the project root path' do
        @project.paths.root.should ==
          Pathname.new(fixture_path(:directory_config))
      end

      it 'should set the configuration file path' do
        @project.paths.config.should == Pathname.new(
          fixture_path(:directory_config, 'config', 'montage.yml'))
      end
    end # when given a project root with montage.yml in ./config

    describe 'when given a project subdirectory' do
      before(:all) do
        @project = Montage::Project.find(fixture_path(:subdirs, 'sub', 'sub'))
      end

      it 'should set the project root path' do
        @project.paths.root.should ==
          Pathname.new(fixture_path(:subdirs))
      end

      it 'should set the configuration file path' do
        @project.paths.config.should ==
          Pathname.new(fixture_path(:subdirs, 'montage.yml'))
      end
    end # when given a project subdirectory

    describe 'when given a configuration file in the root' do
      before(:all) do
        @project = Montage::Project.find(
          fixture_path(:root_config, 'montage.yml'))
      end

      it 'should set the project root path' do
        @project.paths.root.should ==
          Pathname.new(fixture_path(:root_config))
      end

      it 'should set the configuration file path' do
        @project.paths.config.should ==
          Pathname.new(fixture_path(:root_config, 'montage.yml'))
      end
    end # when given a configuration file in the root

    describe 'when given a configuration file in ./config' do
      before(:all) do
        @project = Montage::Project.find(
          fixture_path(:directory_config, 'config', 'montage.yml'))
      end

      it 'should set the project root path' do
        @project.paths.root.should ==
          Pathname.new(fixture_path(:directory_config))
      end

      it 'should set the configuration file path' do
        @project.paths.config.should == Pathname.new(
          fixture_path(:directory_config, 'config', 'montage.yml'))
      end
    end # when given a configuration file in ./config

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
