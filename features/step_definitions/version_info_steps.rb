# Results --------------------------------------------------------------------

Then /^the stdout should contain the Flexo version$/ do
  Then %(the stdout should contain "#{Flexo::VERSION}")
end
