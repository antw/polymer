require 'spec_helper'

# ----------------------------------------------------------------------------

context 'Generating a new project in the current directory' do
  before(:all) do
    @runner = Flexo::Spec::InitCommandRunner.new.run!
  end

  it { @runner.should be_success }
  it { @runner.stdout.should =~ /Your project was created/ }
  it { @runner.path_to_file('.flexo').should be_file }

  # Example sources?

  it 'should copy the sample source images' do
    %w( one/book one/box-label one/calculator
        one/calendar-month one/camera one/eraser
        two/inbox-image two/magnet two/newspaper
        two/wand-hat two/wooden-box-label ).each do |source|
      @runner.path_to_source(source).should be_file
    end
  end

  # Config

  describe 'the .flexo file' do
    before(:all) do
      @config = File.read(@runner.project.paths.config)
    end

    it { @config.should =~ %r|^  "public/images/sprites/:name/\*\.\{png,jpg,jpeg,gif\}":$| }
    it { @config.should =~ %r|^    to: "public/images/:name\.png"$| }
  end
end

# ----------------------------------------------------------------------------

context 'Generating a new project in an existing project directory' do
  before(:all) do
    @runner = Flexo::Spec::InitCommandRunner.new
    2.times { @runner.run! }
  end

  it { @runner.should be_failure }
  it { @runner.stdout.should =~ /A Flexo project already exists in the current directory/ }
end

# ----------------------------------------------------------------------------

context 'Generating a new project with a custom sprites directory' do
  describe 'the .flexo file' do
    before(:all) do
      @runner = Flexo::Spec::InitCommandRunner.new(
        :sprites => 'public/other').run!

      @config = File.read(@runner.project.paths.config)
    end

    it { @config.should =~ %r|^  "public/other/sprites/:name/\*\.\{png,jpg,jpeg,gif\}":$| }
    it { @config.should =~ %r|^    to: "public/other/:name\.png"$| }
  end
end

# ----------------------------------------------------------------------------

context 'Generating a new project with an absolute custom sprites directory' do
  describe 'the .flexo file' do
    before(:all) do
      @runner = Flexo::Spec::InitCommandRunner.new(
        :sprites => '/tmp').run!

      @config = File.read(@runner.project.paths.config)
    end

    it { @config.should =~ %r|^  "/tmp/sprites/:name/\*\.\{png,jpg,jpeg,gif\}":$| }
    it { @config.should =~ %r|^    to: "/tmp/:name\.png"$| }
  end
end

# ----------------------------------------------------------------------------

context 'Generating a new project with a custom sprites and sources directory' do
  describe 'the .flexo file' do
    before(:all) do
      @runner = Flexo::Spec::InitCommandRunner.new(
        :sprites => 'public/other', :sources => 'src/sprites').run!

      @config = File.read(@runner.project.paths.config)
    end

    it { @config.should =~ %r|^  "src/sprites/:name/\*\.\{png,jpg,jpeg,gif\}":$| }
    it { @config.should =~ %r|^    to: "public/other/:name\.png"$| }
  end
end
