require File.expand_path('../../../spec_helper', __FILE__)

context 'Generating a new project in the current directory' do
  before(:all) do
    @runner = Montage::Spec::CommandRunner.new('montage init').run!
  end

  it { @runner.should be_success }
  it { @runner.stdout.should =~ /Your project was created/ }
  it { @runner.path_to_file('montage.yml').should be_file }
end

context 'Generating a new project in a path which has a ./config directory' do
  before(:all) do
    @runner = Montage::Spec::CommandRunner.new('montage init')
    @runner.mkdir('config')
    @runner.run!
  end

  it { @runner.should be_success }
  it { @runner.stdout.should =~ /Your project was created/ }
  it { @runner.path_to_file('config/montage.yml').should be_file }
  it { @runner.path_to_file('montage.yml').should_not be_file }
end

context 'Generating a new project in an existing project directory' do
  before(:all) do
    @runner = Montage::Spec::CommandRunner.new('montage init')
    2.times { @runner.run! }
  end

  it { @runner.should be_failure }
  it { @runner.stdout.should =~ /A Montage project already exists in the current directory/ }
end

context 'Generating a new project in an existing project which has a ./config directory' do
  before(:all) do
    @runner = Montage::Spec::CommandRunner.new('montage init')
    @runner.mkdir('config')
    2.times { @runner.run! }
  end

  it { @runner.should be_failure }
  it { @runner.stdout.should =~ /A Montage project already exists in the current directory/ }
end
