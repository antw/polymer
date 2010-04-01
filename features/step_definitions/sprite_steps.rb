Then %r{^the project should have (\d+) sprites? defined$} do |count|
  project.should have(count.to_i).sprites
end

Then %r{^sprite "([^\"]*)" should have (\d+) sources?$} do |name, count|
  sprite = project.sprites.detect { |s| s.name == name }
  sprite.should have(count.to_i).sources
  sprite.should have(count.to_i).images
end
