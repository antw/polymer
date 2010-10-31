require 'spec_helper'

describe Polymer::Cache do
  subject { Polymer::Cache }

  def sprite(name = 'fry')
    Polymer::DSL.load(path_to_file('.polymer')).sprite(name)
  end

  before(:each) do
    use_helper!

    write_source 'fry/one'
    write_source 'fry/two'
    write_source 'leela/one'

    # Write a cache file.
    path_to_file('.polymer-cache').open('w') do |file|
      file.puts YAML.dump(Polymer::Cache::EMPTY_CACHE.merge(
        :sprites  => {
          'fry'   => project.sprite('fry').digest,
          'leela' => project.sprite('leela').digest
        },
        :paths    => {
          'sources/fry/one.png' =>
            Digest::SHA256.file(path_to_source('fry/one')).to_s,
          'sources/leela/one.png' =>
            Digest::SHA256.file(path_to_source('leela/one')).to_s
        }
      ))
    end

    # Write a fake sprite.
    touch(path_to_sprite('fry'))

    @cache = Polymer::Cache.new(project)
  end

  # --- stale? ---------------------------------------------------------------

  it { should have_public_method_defined(:stale?) }
  it { should have_public_method_defined(:fresh?) }

  describe '#stale?' do
    context 'when given a Sprite' do
      it 'should be false when the sources are unchanged' do
        @cache.stale?(sprite).should be_false
      end

      it 'should be true when the Sprite does not exist on disk' do
        path_to_sprite('fry').unlink
        @cache.stale?(sprite).should be_true
      end

      it 'should be true when a source has been deleted' do
        path_to_source('fry/one').unlink
        @cache.stale?(sprite).should be_true
      end

      it 'should be true when a source has been added' do
        write_source 'fry/three'
        @cache.stale?(sprite).should be_true
      end

      it 'should be true when a source has been changed' do
        write_source 'fry/one', 100
        @cache.stale?(sprite).should be_true
      end

      it 'should be true when given an outdated cache' do
        # Write a cache file.
        path_to_file('.polymer-cache').open('w') do |file|
          file.puts YAML.dump(Polymer::Cache::EMPTY_CACHE.merge(
            :sprites => { 'fry' => project.sprite('fry').digest },
            :cache_version => Polymer::Cache::CACHE_VERSION - 1
          ))
        end

        cache = Polymer::Cache.new(project)
        cache.stale?(sprite).should be_true
      end
    end # when given a Sprite

    context 'when given a Pathname' do
      before(:each) do
        @full_path = path_to_source 'fry/one'
        @pathname  = Pathname.new('sources/fry/one.png')
      end

      context 'when the cache is backed by a file' do
        it 'should be true when the file does not exist' do
          @full_path.unlink
          in_project_dir { @cache.stale?(@pathname).should be_true }
        end

        it 'should be true when the file digest has changed' do
          write_source 'fry/one', 100

          in_project_dir do
            @cache.stale?(@pathname).should be_true
          end
        end

        it 'should be false if the file digest is unchanged' do
          in_project_dir do
            @cache.stale?(@pathname).should be_false
          end
        end

        it 'should be false if given a different path to an unchanged file' do
          in_project_dir do
            @cache.stale?(@pathname + 'something/..').should be_false
          end
        end
      end # when the cache is backed by a file

      context 'when the cache is temporary' do
        before(:each) do
          @cache = Polymer::Cache.new
          in_project_dir { @cache.set(@pathname) }
        end

        it 'should be true when the file digest has changed' do
          write_source 'fry/one', 100

          in_project_dir do
            @cache.stale?(@pathname).should be_true
          end
        end

        it 'should be false if the file digest is unchanged' do
          in_project_dir do
            @cache.stale?(@pathname).should be_false
          end
        end

        it 'should be false if given a different path to an unchanged file' do
          in_project_dir do
            @cache.stale?(@pathname + 'something/..').should be_false
          end
        end
      end # when the cache is temporary

    end # when given a Pathname
  end # #stale?

  # --- write ----------------------------------------------------------------

  it { should have_public_method_defined(:write) }

  describe '#write' do
    context 'when the file does not exist' do
      before(:each) { path_to_file('.polymer-cache').unlink }

      it 'should create the file' do
        lambda { @cache.write }.should change {
          path_to_file('.polymer-cache').file?
        }
      end

      it 'should return true' do
        @cache.write.should be_true
      end
    end

    context 'when created without a project' do
      it 'should return false' do
        Polymer::Cache.new.write.should be_false
      end
    end
  end # #write

  # --- set ------------------------------------------------------------------

  it { should have_public_method_defined(:set) }

  describe '#set' do
    context 'when given a Sprite' do
      it 'should set the new sprite digest' do
        path_to_source('fry/one').unlink

        @cache.set(sprite)
        @cache.stale?(sprite).should be_false
      end
    end

    context 'when given a Pathname' do
      it 'should set the new file digest' do
        write_source 'fry/one', 100

        path = Pathname.new('sources/fry/one.png')

        in_project_dir do
          @cache.set(path)
          @cache.stale?(path).should be_false
        end
      end
    end
  end # #set

  # --- remove ---------------------------------------------------------------

  it { should have_public_method_defined(:remove) }

  describe '#remove' do
    it 'should remove the cache entry' do
      @cache.remove(sprite)
      @cache.stale?(sprite).should be_true
    end

    it 'should remove the path entry' do
      path = Pathname.new('sources/fry/one.png')

      in_project_dir do
        @cache.remove(path)
        @cache.stale?(path).should be_true
      end
    end
  end # #remove

  # --- clean! ---------------------------------------------------------------

  it { should have_public_method_defined(:clean!) }

  describe '#clean!' do
    before(:each) do
      @old_sprite = sprite('leela')
      path_to_source('leela/one').unlink
    end

    it 'should remove deleted sprites' do
      @cache.clean!

      @cache.stale?(sprite('fry')).should be_false
      @cache.stale?(@old_sprite).should be_true
    end

    it 'should remove deleted images' do
      @cache.clean!

      in_project_dir do
        @cache.stale?(Pathname.new('sources/fry/one.png')).should be_false
        @cache.stale?(Pathname.new('sources/leela/one.png')).should be_true
      end
    end

    it 'should remove paths which are not in a subtree' do
      non_subtree = Pathname.new(Dir.mktmpdir) + 'a_file'

      begin
        FileUtils.touch(non_subtree)
        @cache.set(non_subtree)
        @cache.stale?(non_subtree).should be_false
        @cache.clean!
        @cache.stale?(non_subtree).should be_true
      ensure
        FileUtils.remove_entry_secure(non_subtree.dirname)
      end
    end

    it 'should return false if no path is set' do
      Polymer::Cache.new.clean!.should be_false
    end
  end

end
