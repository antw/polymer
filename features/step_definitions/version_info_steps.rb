# Results --------------------------------------------------------------------

Then /^the stdout should contain the Polymer version$/ do
  Then %(the stdout should contain "#{Polymer::VERSION}")
end
