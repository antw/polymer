require File.expand_path('../../../spec_helper', __FILE__)

# ----------------------------------------------------------------------------

context 'Generating a new project in the current directory' do
  before(:all) do
    @runner = Montage::Spec::InitCommandRunner.new.run!
  end

  it { @runner.should be_success }
  it { @runner.stdout.should =~ /Your project was created/ }
  it { @runner.path_to_file('montage.yml').should be_file }

  # Example sources?

  it 'should copy the sample source images' do
    %w( book box-label calculator calendar-month camera eraser ).each do |source|
      (@runner.project.paths.sources + "#{source}.png").should be_file
    end
  end

  # Config

  describe 'the montage.yml file' do
    before(:all) do
      @config = File.read(@runner.project.paths.config)
    end

    it { @config.should =~ %r{^  config.sprites:\s+"public/images/sprites"$} }
    it { @config.should =~ %r{^  config.sources:\s+"public/images/sprites/src"$} }
  end
end

# ----------------------------------------------------------------------------

context 'Generating a new project in a path which has a ./config directory' do
  before(:all) do
    @runner = Montage::Spec::InitCommandRunner.new
    @runner.mkdir('config')
    @runner.run!
  end

  it { @runner.should be_success }
  it { @runner.stdout.should =~ /Your project was created/ }
  it { @runner.path_to_file('config/montage.yml').should be_file }
  it { @runner.path_to_file('montage.yml').should_not be_file }
end

# ----------------------------------------------------------------------------

context 'Generating a new project in an existing project directory' do
  before(:all) do
    @runner = Montage::Spec::InitCommandRunner.new
    2.times { @runner.run! }
  end

  it { @runner.should be_failure }
  it { @runner.stdout.should =~ /A Montage project already exists in the current directory/ }
end

# ----------------------------------------------------------------------------

context 'Generating a new project in an existing project which has a ./config directory' do
  before(:all) do
    @runner = Montage::Spec::InitCommandRunner.new
    @runner.mkdir('config')
    2.times { @runner.run! }
  end

  it { @runner.should be_failure }
  it { @runner.stdout.should =~ /A Montage project already exists in the current directory/ }
end

# ----------------------------------------------------------------------------

context 'Generating a new project with a custom sprites directory' do
  describe 'the montage.yml file' do
    before(:all) do
      @runner = Montage::Spec::InitCommandRunner.new(
        :sprites => 'public/other').run!

      @config = File.read(@runner.project.paths.config)
    end

    it { @config.should =~ %r{^  config.sprites:\s+"public/other"$} }
    it { @config.should =~ %r{^  config.sources:\s+"public/other/src"$} }
  end
end

# ----------------------------------------------------------------------------

context 'Generating a new project with an absolute custom sprites directory' do
  describe 'the montage.yml file' do
    before(:all) do
      @runner = Montage::Spec::InitCommandRunner.new(
        :sprites => '/tmp').run!

      @config = File.read(@runner.project.paths.config)
    end

    it { @config.should =~ %r{^  config.sprites:\s+"/tmp"$} }
    it { @config.should =~ %r{^  config.sources:\s+"/tmp/src"$} }
  end
end

# ----------------------------------------------------------------------------

context 'Generating a new project with a custom sprites and sources directory' do
  describe 'the montage.yml file' do
    before(:all) do
      @runner = Montage::Spec::InitCommandRunner.new(
        :sprites => 'public/other', :sources => 'src/sprites').run!

      @config = File.read(@runner.project.paths.config)
    end

    it { @config.should =~ %r{^  config.sprites:\s+"public/other"$} }
    it { @config.should =~ %r{^  config.sources:\s+"src/sprites"$} }
  end
end
