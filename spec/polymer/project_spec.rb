require 'spec_helper'

describe Polymer::Project do
  subject { Polymer::Project }

  # Class Methods ============================================================

  # --- find_config ----------------------------------------------------------

  it { should respond_to(:find_config) }

  describe '.find_config' do
    before(:each) do
      use_helper!

      # Remove the default config -- we'll create our own.
      path_to_file('.polymer').unlink
    end

    context 'when given a project root, with .polymer present' do
      it 'should return a path to .polymer' do
        touch '.polymer'

        path = Polymer::Project.find_config(project_dir)
        path.should == path_to_file('.polymer')
      end
    end # when given a project root, with .polymer present

    context 'when given a project root, with polymer.rb present' do
      it 'should return a path to polymer.rb' do
        touch 'polymer.rb'

        path = Polymer::Project.find_config(project_dir)
        path.should == path_to_file('polymer.rb')
      end
    end # when given a project root, with polymer.rb present

    context 'when given a project sub-dir, with .polymer in a parent' do
      it 'should return a path to .polymer' do
        mkdir 'sub/sub'
        touch '.polymer'

        path = Polymer::Project.find_config(project_dir + 'sub/sub')
        path.should == path_to_file('.polymer')
      end
    end # when given a project sub-dir, with .polymer in a parent

    context 'when given a project sub-dir, with polymer.rb in a parent' do
      it 'should return a path to polymer.rb' do
        mkdir 'sub/sub'
        touch 'polymer.rb'

        path = Polymer::Project.find_config(project_dir + 'sub/sub')
        path.should == path_to_file('polymer.rb')
      end
    end # when given a project sub-dir, with polymer.rb in a parent

    context 'when given a path to a file' do
      it 'should return a path to the file' do
        touch '.polymer'
        Polymer::Project.find_config(path_to_file('.polymer'))
      end
    end # when given a path to a file

    context 'when given an empty directory' do
      it 'should raise an error' do
        running = lambda { Polymer::Project.find_config(project_dir) }
        running.should raise_error(Polymer::MissingProject)
      end
    end # when given an empty directory

    context 'when given an invalid path' do
      it 'should raise an error' do
        running = lambda { Polymer::Project.find_config('__invalid__') }
        running.should raise_error(Polymer::MissingProject)
      end
    end # when given an invalid path
  end

  # Instance Methods =========================================================

  it { should have_public_method_defined(:root) }

  # --- sprites --------------------------------------------------------------

  it { should have_public_method_defined(:sprites) }

  describe '#sprites' do
    context "when the project has one sprite with two sources" do
      before(:each) do
        use_helper!

        write_source 'sprite_one/one', 100, 25
        write_source 'sprite_one/two', 100, 25
      end

      it 'should return an array with one element' do
        project.sprites.should have(1).sprite
      end

      it 'should have two sources in the sprite' do
        project.sprites.first.should have(2).sources
      end
    end # when the project has one sprite with two sources

    context "when the project has two sprites with 2/1 sources" do
      before(:each) do
        use_helper!

        write_source 'sprite_one/one',   100, 25
        write_source 'sprite_one/two',   100, 25
        write_source 'sprite_two/three', 100, 25
      end

      it 'should return an array with two elements' do
        project.sprites.should have(2).sprite
      end

      it 'should have two sources in the first sprite' do
        project.sprite('sprite_one').should have(2).sources
      end

      it 'should have one source in the second sprite' do
        project.sprite('sprite_two').should have(1).sources
      end
    end # when the project has one sprite with two sources

  end

  # --- cache ----------------------------------------------------------------

  describe 'cache' do
    it 'should return a instance of Polymer::Cache' do
      use_helper!
      project.cache.should be_a(Polymer::Cache)
    end
  end # #cache

end
