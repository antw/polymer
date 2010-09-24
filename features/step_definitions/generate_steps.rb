# Steps ----------------------------------------------------------------------

Given /^I have a default project$/ do
  create_default_project!
end

Given /^I have a project with config:$/ do |config|
  command.write_config config
end

Given /^I have (\d+) sources? in (.+)$/ do |num_sources, dir|
  command.mkdir(dir)
  num_sources = num_sources.to_i

  # Determine the sprite name.
  sprite = dir.split('/').last

  names = %w( one two three four five )
  num_sources.times { |idx| command.write_source "#{sprite}/#{names[idx]}" }
end

Given /^I have a "(.+)" source at (.+) which is (\d+)x(\d+)$/ do |source, dir, w, h|
  # Determine the sprite name.
  sprite = dir.split('/').last

  command.mkdir(dir)
  command.write_source "#{sprite}/#{source}", w.to_i, h.to_i
end

Given /^I have a (.+) image$/ do |path|
  command.write_image path
end

Given /^(.+) is not writable$/ do |path|
  path = command.path_to_file(path)
  path.mkpath unless path.file?

  # Keep track of the file's original attribtues so they can be restored.
  chmods[path] ||= path.stat.mode
  path.chmod(path.directory? ? 040555 : 0100444)
end

# Results --------------------------------------------------------------------

Then /^the "(.*)" sprite should have been (?:re-)?generated$/ do |sprite|
  Then %[the "#{sprite}" sprite should exist]
  Then %[the stdout should contain "generated  #{sprite}"]
end

Then /^the "(.*)" sprite should not have been (?:re-)?generated$/ do |sprite|
  Then %[the stdout should not contain "generated  #{sprite}"]
end

Then /^the "(.*)" sprite should have been optimised$/ do |sprite|
  Then %[the stdout should contain "optimised  #{sprite}"]
end

Then /^the "(.*)" sprite should not have been optimised$/ do |sprite|
  Then %[the stdout should not contain "optimised  #{sprite}"]
end

Then /^the "(.+)" sprite should exist$/ do |sprite|
  command.path_to_sprite(sprite).should be_file
end

Then /^the "(.+)" sprite should be (\d+)x(\d+)$/ do |sprite, w, h|
  command.dimensions_of(sprite).should == [w.to_i, h.to_i]
end

Then /^a Sass mixin should exist$/ do
  command.path_to_file('public/stylesheets/sass/_polymer.sass').should be_file
end

Then /^a Sass mixin should not exist$/ do
  command.path_to_file('public/stylesheets/sass/_polymer.sass').should_not be_file
end
