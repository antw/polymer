$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'tmpdir'

require 'rubygems'
require 'rspec/core'

require 'flexo'
require 'sass'

# Spec libraries.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.after(:suite) { Flexo::Spec::ProjectHelper.cleanup! }

  config.include Flexo::Spec::Helper
  config.include Flexo::Spec::Sass
end
