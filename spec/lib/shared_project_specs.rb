describe 'a project with correct paths', :shared => true do
  # Requires:
  #
  #   @project => Montage::Project
  #   @helper  => Montage::Spec::ProjectHelper
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

  it 'should set the sources path' do
    @project.paths.sources.should == @root + 'public/images/sprites/src'
  end

  it 'should set the sprite path' do
    @project.paths.sprites.should == @root + 'public/images/sprites'
  end

  it 'should set the SASS output path' do
    @project.paths.sass.should == @root + 'public/stylesheets/sass'
  end

  it 'should set the CSS sprite URL' do
    @project.paths.url.should == '/images/sprites'
  end
end