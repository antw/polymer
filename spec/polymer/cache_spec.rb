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
        :sprites => { 'fry' => project.sprite('fry').digest }
      ))
    end

    # Write a fake sprite.
    touch(path_to_sprite('fry'))

    @cache = Polymer::Cache.new(path_to_file('.polymer-cache'))
  end

  # --- stale? ---------------------------------------------------------------

  it { should have_public_method_defined(:stale?) }
  it { should have_public_method_defined(:fresh?) }

  describe '#stale?' do
    context 'when given a sprite which does not exist on disk' do
      it 'should return true' do
        path_to_sprite('fry').unlink
        @cache.stale?(sprite).should be_true
      end
    end

    context 'when given a sprite whose sources are unchanged' do
      it 'should return false' do
        @cache.stale?(sprite).should be_false
      end
    end

    context 'when given a sprite with a deleted source' do
      it 'should return true' do
        path_to_source('fry/one').unlink
        @cache.stale?(sprite).should be_true
      end
    end

    context 'when given a sprite with a new source' do
      it 'should be true' do
        write_source('fry/three')
        @cache.stale?(sprite).should be_true
      end
    end

    context 'when given a sprite with a changed source' do
      it 'should be true' do
        write_source('fry/one', 100)
        @cache.stale?(sprite).should be_true
      end
    end

    context 'when given an outdated cache' do
      it 'should be true' do
        # Write a cache file.
        path_to_file('.polymer-cache').open('w') do |file|
          file.puts YAML.dump(Polymer::Cache::EMPTY_CACHE.merge(
            :sprites => { 'fry' => project.sprite('fry').digest },
            :cache_version => Polymer::Cache::CACHE_VERSION - 1
          ))
        end

        cache = Polymer::Cache.new(path_to_file('.polymer-cache'))
        cache.stale?(sprite).should be_true
      end
    end
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

    context 'when created without a path' do
      it 'should return false' do
        Polymer::Cache.new.write.should be_false
      end
    end
  end # #write

  # --- set ------------------------------------------------------------------

  it { should have_public_method_defined(:set) }

  describe '#set' do
    it 'should set the new sprite digest' do
      path_to_source('fry/one').unlink

      @cache.set(sprite)
      @cache.stale?(sprite).should be_false
    end
  end # #set

  # --- remove ---------------------------------------------------------------

  it { should have_public_method_defined(:remove) }

  describe '#remove' do
    it 'should remove the cache entry' do
      @cache.remove(sprite)
      @cache.stale?(sprite).should be_true
    end
  end # #remove

  # --- remove_all_except ----------------------------------------------------

  it { should have_public_method_defined(:remove_all_except) }

  describe '#remove_all_except' do
    it 'should remove excluded cache entries' do
      @cache.remove_all_except([sprite('fry')])

      @cache.stale?(sprite('fry')).should be_false
      @cache.stale?(sprite('leela')).should be_true
    end
  end

end
