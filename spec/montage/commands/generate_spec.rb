require File.expand_path('../../../spec_helper', __FILE__)

# ----------------------------------------------------------------------------

context 'Generating a single sprite with two sources' do
  before(:all) do
    @runner = Montage::Spec::CommandRunner.new('montage')
    @runner.write_config <<-CONFIG
      ---
        sprite_one:
          - one
          - two
    CONFIG
    @runner.write_source('one')
    @runner.write_source('two')
    @runner.run!
  end

  it { @runner.should be_success }
  it { @runner.stdout.should =~ /sprite_one: Generated/ }
  it { @runner.path_to_sprite('sprite_one').should be_file }
  it { @runner.dimensions_of('sprite_one').should == [50, 60] }
end

# ----------------------------------------------------------------------------

context 'Generating multiple sprites' do
  before(:all) do
    @runner = Montage::Spec::CommandRunner.new('montage')
    @runner.write_config <<-CONFIG
      ---
        sprite_one:
          - one

        sprite_two:
          - two
          - three
    CONFIG
    @runner.write_source('one')
    @runner.write_source('two')
    @runner.write_source('three', 200, 200)
    @runner.run!
  end

  it { @runner.should be_success }

  it { @runner.stdout.should =~ /sprite_one: Generated/ }
  it { @runner.path_to_sprite('sprite_one').should be_file }
  it { @runner.dimensions_of('sprite_one').should == [50, 20] }

  it { @runner.stdout.should =~ /sprite_two: Generated/ }
  it { @runner.path_to_sprite('sprite_two').should be_file }
  it { @runner.dimensions_of('sprite_two').should == [200, 240] }
end

# ----------------------------------------------------------------------------

context 'Generating a single sprite with custom padding' do
  before(:all) do
    @runner = Montage::Spec::CommandRunner.new('montage')
    @runner.write_config <<-CONFIG
      ---
        config.padding: 50

        sprite_one:
          - one
          - two
    CONFIG
    @runner.write_source('one')
    @runner.write_source('two')
    @runner.run!
  end

  it { @runner.should be_success }
  it { @runner.stdout.should =~ /sprite_one: Generated/ }
  it { @runner.path_to_sprite('sprite_one').should be_file }
  it { @runner.dimensions_of('sprite_one').should == [50, 90] }
end

# ----------------------------------------------------------------------------

context 'Trying to generate sprites in a non-project directory' do
  before(:all) do
    @runner = Montage::Spec::CommandRunner.new('montage').run!
  end

  it { @runner.should be_failure }
  it { @runner.stdout.should =~ /Couldn't find a Montage project/ }
end

# ----------------------------------------------------------------------------

context 'Trying to generate sprites when a source is missing' do
  before(:all) do
    @runner = Montage::Spec::CommandRunner.new('montage')
    @runner.write_config <<-CONFIG
      ---
        sprite_one:
          - one
    CONFIG
    @runner.mkdir('public/images/sprites/src')
    @runner.run!
  end

  it { @runner.should be_failure }
  it { @runner.stdout.should =~ /Couldn't find a matching file for source image `one'/ }
end

# ----------------------------------------------------------------------------

context 'Trying to generate sprites when the source directory' do
  before(:all) do
    @runner = Montage::Spec::CommandRunner.new('montage')
    @runner.write_config <<-CONFIG
      ---
        sprite_one:
          - one
    CONFIG
    @runner.run!
  end

  it { @runner.should be_failure }
  it { @runner.stdout.should =~ /Montage can't save the sprite in/ }
end
