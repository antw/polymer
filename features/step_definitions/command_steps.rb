# From -- or heavily inspired by -- Aruba.
# http://github.com/aslakhellesoy/aruba/blob/master/lib/aruba/cucumber.rb

# Steps ----------------------------------------------------------------------

When /^I run "(.+)"$/ do |command|
  run(command)
end

When /^I delete the file (.*)$/ do |path|
  command.path_to_file(path).unlink
end

When /^I change directory to (.+)$/ do |path|
  path = path.chomp!('/')
  @previous_directory = Dir.pwd unless @previous_directory
  command.mkdir(path)
  Dir.chdir command.project_dir + path
end

# Results --------------------------------------------------------------------

Then /^the output should contain "(.+)"$/ do |partial_output|
  combined_output.should =~ compile_and_escape(partial_output)
end

Then /^the output should not contain "(.+)"$/ do |partial_output|
  combined_output.should_not =~ compile_and_escape(partial_output)
end

Then /^the output should contain:$/ do |partial_output|
  combined_output.should =~ compile_and_escape(partial_output)
end

Then /^the output should not contain:$/ do |partial_output|
  combined_output.should_not =~ compile_and_escape(partial_output)
end

Then /^the output should contain exactly "(.+)"$/ do |exact_output|
  combined_output.should == unescape(exact_output)
end

Then /^the output should contain exactly:$/ do |exact_output|
  combined_output.should == exact_output
end

# "the output should match" allows regex in the partial_output, if
# you don't need regex, use "the output should contain" instead since
# that way, you don't have to escape regex characters that
# appear naturally in the output
Then /^the output should match \/([^\/]*)\/$/ do |partial_output|
  combined_output.should =~ /#{partial_output}/
end

Then /^the output should match:$/ do |partial_output|
  combined_output.should =~ /#{partial_output}/m
end

Then /^the exit status should be (\d+)$/ do |exit_status|
  status.should == exit_status.to_i
end

Then /^the exit status should not be (\d+)$/ do |exit_status|
  status.should_not == exit_status.to_i
end

Then /^the stderr should contain "(.+)"$/ do |partial_output|
  stderr.should =~ compile_and_escape(partial_output)
end

Then /^the stdout should contain "(.+)"$/ do |partial_output|
  stdout.should =~ compile_and_escape(partial_output)
end

Then /^the stderr should not contain "(.+)"$/ do |partial_output|
  stderr.should_not =~ compile_and_escape(partial_output)
end

Then /^the stdout should not contain "(.+)"$/ do |partial_output|
  stdout.should_not =~ compile_and_escape(partial_output)
end

Then /^(.*) should be a file$/ do |path|
  command.path_to_file(path).should be_file
end

Then /^the file (.+) should contain "(.+)"$/ do |path, partial_content|
  command.path_to_file(path).read.should =~ compile_and_escape(partial_content)
end

Then /^the file (.+) should not contain "(.+)"$/ do |file, partial_content|
  command.path_to_file(path).read.should_not =~ compile_and_escape(partial_content)
end
