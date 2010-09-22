# Steps ----------------------------------------------------------------------

When /^I run "flexo init" with:$/ do |settings|
  settings = settings.split("\n").inject({}) do |hash, line|
    key, value = line.split(':').map { |v| v.strip }
    hash[key] = value
    hash
  end

  run('flexo init') do |stdin|
    stdin.puts settings.fetch('sprites', "\n")
    stdin.puts settings.fetch('sources', "\n")
  end
end

# Results --------------------------------------------------------------------

Then /^the fixture sources should exist in (.*)$/ do |directory|
  directory = command.path_to_file(directory)

  sources = %w(
      one/book one/box-label one/calculator
      one/calendar-month one/camera one/eraser

      two/inbox-image two/magnet two/newspaper
      two/television two/wand-hat two/wooden-box-label )

  sources.each do |source|
    (directory + "#{source}.png").should be_file
  end
end

Then /^the fixture sources should not exist$/ do
  command.path_to_file('public/images/sprites').should_not be_directory
end

flexofile = "(#{Regexp.escape('.flexo')}|#{Regexp.escape('flexo.rb')})"

Then /^#{flexofile} should expect default sources in (.+)$/ do |config, directory|
  command.path_to_file(config).read.should =~
    compile_and_escape("#{directory}/:name/*")
end

Then /^#{flexofile} should expect default sprites to be saved in (.+)$/ do |config, directory|
  command.path_to_file(config).read.should =~
    compile_and_escape("#{directory}/:name.png")
end

Then /^#{flexofile} should expect the cache to be at (.+)$/ do |config, path|
  command.path_to_file(config).read.should =~
    compile_and_escape("config.cache '#{path}'")
end
