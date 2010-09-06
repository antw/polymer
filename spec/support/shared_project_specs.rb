shared_examples_for 'a project with correct paths' do
  # Requires:
  #
  #   @project => Flexo::Project
  #   @helper  => Flexo::Spec::ProjectHelper
  #   @config  => Pathname (path to config file)
  #
  #   (optional)
  #   @root    => Pathname (path to the root of the project)
  #

  before(:all) do
    @root ||= @helper.project_dir
  end

  it 'should set the project root path' do
    @project.paths.root.should == @root
  end

  it 'should set the configuration file path' do
    @project.paths.config.should == @config
  end

  it 'should set the cache file path' do
    cache_path = @cache.nil? ? Pathname.new(@config.to_s + '-cache') : @cache
    @project.paths.cache.should == cache_path
  end

  it 'should set the SASS output path' do
    @project.paths.sass.should == @root + 'public/stylesheets/sass'
  end

  it 'should set the CSS sprite URL' do
    @project.paths.url.should == '/images/:name.png'
  end
end
