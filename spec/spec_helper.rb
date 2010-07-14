$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'tmpdir'

require 'rubygems'
require 'rspec/core'
require 'rspec/autorun'

require 'montage'
require 'sass'

# Spec libraries.
Dir["#{File.dirname(__FILE__)}/lib/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.after(:suite) { Montage::Spec::ProjectHelper.cleanup! }
end
