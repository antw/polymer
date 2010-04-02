##
# Provides assistance when dealing with a fixture.
#
class FixtureHelper
  FIXTURES_DIR = Pathname.new(__FILE__).dirname + '../fixtures'

  attr_reader :root, :project

  def initialize(fixture_name = :default)
    @root = Dir.mktmpdir

    # Copy the fixture to a temporary location.
    files = (Dir[FIXTURES_DIR + "#{fixture_name}/*"] +
             Dir[FIXTURES_DIR + "#{fixture_name}/**/*"]).uniq

    FileUtils.cp_r(files, @root)

    reload!
  end

  # Updates montage.yml with new contents.
  def replace_config(config)
    File.open(@project.paths.config, 'w') { |f| f.puts(config) }
  end

  # Replaces an image file.
  def replace_source(source, with)
    FileUtils.cp(
      FIXTURES_DIR + "sources/#{with}.png",
      @project.paths.sources + "#{source}.png")
  end

  def reload!
    @project = Montage::Project.find(@root)
  end

  # Removes temporary products.
  def cleanup!
    FileUtils.remove_entry_secure(@root)
  end
end
