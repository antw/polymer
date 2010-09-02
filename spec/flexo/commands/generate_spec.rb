require 'spec_helper'

# ----------------------------------------------------------------------------

context 'Generating a single sprite with two sources' do
  before(:all) do
    @runner = Flexo::Spec::CommandRunner.new('flexo')
    @runner.write_simple_config
    @runner.write_source('sprite_one/one')
    @runner.write_source('sprite_one/two')
    @runner.run!
  end

  it { @runner.should be_success }
  it { @runner.stderr.should == '' }
  it { @runner.stdout.should =~ /Generating "sprite_one": Done/ }
  it { @runner.path_to_sprite('sprite_one').should be_file }
  it { @runner.dimensions_of('sprite_one').should == [50, 60] }

  # Sass.
  it { @runner.path_to_file('public/stylesheets/sass/_flexo.sass').should be_file }

  # PNGOut.
  it { @runner.stdout.should =~ /Optimising "sprite_one": Done/ }
end

# ----------------------------------------------------------------------------

context 'Generating multiple sprites' do
  before(:all) do
    @runner = Flexo::Spec::CommandRunner.new('flexo')
    @runner.write_simple_config
    @runner.write_source('sprite_one/one')
    @runner.write_source('sprite_two/two')
    @runner.write_source('sprite_two/three', 200, 200)
    @runner.run!
  end

  it { @runner.should be_success }

  it { @runner.stdout.should =~ /Generating "sprite_one": Done/ }
  it { @runner.path_to_sprite('sprite_one').should be_file }
  it { @runner.dimensions_of('sprite_one').should == [50, 20] }

  it { @runner.stdout.should =~ /Generating "sprite_two": Done/ }
  it { @runner.path_to_sprite('sprite_two').should be_file }
  it { @runner.dimensions_of('sprite_two').should == [200, 240] }

  # PNGOut.
  it { @runner.stdout.should =~ /Optimising "sprite_one": Done/ }
  it { @runner.stdout.should =~ /Optimising "sprite_two": Done/ }
end

# ----------------------------------------------------------------------------

context 'Generating a single sprite with custom padding' do
  before(:all) do
    @runner = Flexo::Spec::CommandRunner.new('flexo')
    @runner.write_config <<-CONFIG
      ---
        config.padding: 50

        "public/images/sprites/:name/*.{png,jpg,jpeg,gif}":
          to: "public/images/:name.png"

    CONFIG
    @runner.write_source('sprite_one/one')
    @runner.write_source('sprite_one/two')
    @runner.run!
  end

  it { @runner.should be_success }
  it { @runner.stdout.should =~ /Generating "sprite_one": Done/ }
  it { @runner.path_to_sprite('sprite_one').should be_file }
  it { @runner.dimensions_of('sprite_one').should == [50, 90] }
end

# ----------------------------------------------------------------------------

context 'Generating a single sprite with zero padding' do
  before(:all) do
    @runner = Flexo::Spec::CommandRunner.new('flexo')
    @runner.write_config <<-CONFIG
      ---
        config.padding: 0

        "public/images/sprites/:name/*.{png,jpg,jpeg,gif}":
          to: "public/images/:name.png"

    CONFIG
    @runner.write_source('sprite_one/one')
    @runner.write_source('sprite_one/two')
    @runner.run!
  end

  it { @runner.should be_success }
  it { @runner.stdout.should =~ /Generating "sprite_one": Done/ }
  it { @runner.path_to_sprite('sprite_one').should be_file }
  it { @runner.dimensions_of('sprite_one').should == [50, 40] }
end

# ----------------------------------------------------------------------------

context 'Trying to generate sprites in a non-project directory' do
  before(:all) do
    @runner = Flexo::Spec::CommandRunner.new('flexo').run!
  end

  it { @runner.should be_failure }
  it { @runner.stdout.should =~ /Couldn't find a Flexo project/ }
end

# ----------------------------------------------------------------------------

context 'Trying to generate sprites when the sprite directory is not writable' do
  before(:all) do
    @runner = Flexo::Spec::CommandRunner.new('flexo')
    @runner.write_simple_config
    @runner.write_source('sprite_one/one')

    output_dir = @runner.path_to_file('public/images')

    old_mode = output_dir.stat.mode
    output_dir.chmod(040555)

    begin
      @runner.run!
    ensure
      output_dir.chmod(old_mode)
    end
  end

  it { @runner.should be_failure }
  it { @runner.stdout.should =~ /can't save the sprite in .* isn't writable/m }
end

# ----------------------------------------------------------------------------

context 'Generating two sprites, one of which is unchanged' do
  before(:all) do
    @runner = Flexo::Spec::CommandRunner.new('flexo')
    @runner.write_simple_config
    @runner.write_source('sprite_one/one')
    @runner.write_source('sprite_one/two')
    @runner.write_source('sprite_two/three')
    @runner.run!

    # Change the 'one' source.
    @runner.write_source('sprite_one/one', 100, 25)
    @runner.run!
  end

  it { @runner.should be_success }

  it { @runner.stdout.should =~ /Generating "sprite_one": Done/ }
  it { @runner.path_to_sprite('sprite_one').should be_file }
  it { @runner.dimensions_of('sprite_one').should == [100, 65] }

  it { @runner.stdout.should =~ /Generating "sprite_two": Unchanged; ignoring/ }
  it { @runner.path_to_sprite('sprite_two').should be_file }
  it { @runner.dimensions_of('sprite_two').should == [50, 20] }

  # PNGOut.
  it { @runner.stdout.should =~ /Optimising "sprite_one": Done/ }
  it { @runner.stdout.should_not =~ /Optimising "sprite_two": Done/ }
end

# ----------------------------------------------------------------------------

context 'Generating two sprites, one of which is unchanged when using the --force option' do
  before(:all) do
    @runner = Flexo::Spec::CommandRunner.new('flexo')
    @runner.write_simple_config
    @runner.write_source('sprite_one/one')
    @runner.write_source('sprite_one/two')
    @runner.write_source('sprite_two/three')
    @runner.run!

    # Change the 'one' source.
    @runner.write_source('one', 100, 25)
    @runner.run('flexo --force')
  end

  it { @runner.should be_success }
  it { @runner.stdout.should =~ /Generating "sprite_one": Done/ }
  it { @runner.stdout.should =~ /Generating "sprite_two": Done/ }

  # PNGOut.
  it { @runner.stdout.should =~ /Optimising "sprite_one": Done/ }
  it { @runner.stdout.should =~ /Optimising "sprite_two": Done/ }
end

# ----------------------------------------------------------------------------

context 'Generating an unchanged sprite which has been deleted' do
  before(:all) do
    @runner = Flexo::Spec::CommandRunner.new('flexo')
    @runner.write_simple_config
    @runner.write_source('sprite_one/one')
    @runner.run!

    # Remove the generated sprite.
    @runner.path_to_sprite('sprite_one').unlink
    @runner.run!
  end

  it { @runner.should be_success }

  it { @runner.stdout.should =~ /Generating "sprite_one": Done/ }
  it { @runner.path_to_sprite('sprite_one').should be_file }

  # PNGOut.
  it { @runner.stdout.should =~ /Optimising "sprite_one": Done/ }
end

# ----------------------------------------------------------------------------

context 'Generating sprites with a project which disables Sass' do
  before(:all) do
    @runner = Flexo::Spec::CommandRunner.new('flexo')
    @runner.write_config <<-CONFIG
      ---
        config.sass: false

        "public/images/sprites/:name/*.{png,jpg,jpeg,gif}":
          to: "public/images/:name.png"

    CONFIG
    @runner.write_source('sprite_one/one')
    @runner.run!
  end

  it { @runner.path_to_file('public/stylesheets/sass/_flexo.sass').should_not be_file }
end

# ----------------------------------------------------------------------------

context 'Generating sprites when specifying a custom config file' do
  before(:all) do
    @runner = Flexo::Spec::CommandRunner.new('flexo settings/sprites.yml')
    @runner.write_config 'settings/sprites.yml', <<-CONFIG
      ---
        config.root: '..'

        "public/images/sprites/:name/*.{png,jpg,jpeg,gif}":
          to: "public/images/:name.png"

    CONFIG
    @runner.write_source('sprite_one/one')
    @runner.run!
  end

  it { @runner.should be_success }
  it { @runner.stdout.should =~ /Generating "sprite_one": Done/ }
  it { @runner.path_to_sprite('sprite_one').should be_file }
  it { @runner.path_to_file('public/stylesheets/sass/_flexo.sass').should be_file }
end

# ----------------------------------------------------------------------------

context 'Generating sprites when specifying an invalid custom config file' do
  before(:all) do
    @runner = Flexo::Spec::CommandRunner.new('flexo invalid.yml')
    @runner.run!
  end

  it { @runner.should be_failure }
  it { @runner.stdout.should =~ /Couldn't find `invalid.yml' configuration file/ }
end

# ----------------------------------------------------------------------------

context 'Generating a sprite with wildly varying source widths' do
  before(:all) do
    @runner = Flexo::Spec::CommandRunner.new('flexo')
    @runner.write_simple_config
    @runner.write_source('sprite/one')
    @runner.write_source('sprite/two')
    @runner.write_source('sprite/three')
    @runner.write_source('sprite/four')
    @runner.write_source('sprite/five', 500, 1)
    @runner.run!
  end

  it { @runner.should be_success }
  it { @runner.stdout.should =~ %r{The "five" source image in the "sprite" sprite deviates significantly from the average width} }
end
