##
# Returns the defined project. Sets up the directories if +project+ hasn't
# been called yet.
#
def project
  unless @project
    intermediate = Montage::Project.init(Dir.mktmpdir)

    if @project_config
      File.open(intermediate.paths.config, 'w') do |config|
        config.puts @project_config
      end
    end

    @project = Montage::Project.new(
      intermediate.paths.root, intermediate.paths.config)

    # Copy sprite images.
    FileUtils.mkdir_p(intermediate.paths.sources)
    @project.sprites.each do |sprite|
      sprite.sources.each do |source|
        copy_fixture_image(source, @project.paths.sources + "#{source}.png")
      end
    end
  end

  @project
end

def copy_fixture_image(source, to)
  fixtures = (Pathname.new(__FILE__).dirname + '../support/fixtures')

  from = case source
    when /^mammoth_/ then fixtures + 'five_hundred.png'
    when /^wide_/    then fixtures + 'hundred.png'
    else                  fixtures + 'twenty.png'
  end

  FileUtils.cp(from, to)
end
