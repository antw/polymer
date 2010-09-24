$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'tmpdir'

require 'rubygems'
require 'rspec/core'

require 'polymer'
require 'sass'

# Spec libraries.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.after(:suite) { Polymer::Spec::ProjectHelper.cleanup! }

  config.include Polymer::Spec::Helper
  config.include Polymer::Spec::Sass
end
