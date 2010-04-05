$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'tmpdir'

require 'rubygems'
require 'spec'
require 'spec/autorun'

require 'montage'

# Spec libraries.
spec_libs = Dir.glob(File.expand_path(File.dirname(__FILE__)) + '/lib/**/*.rb')
spec_libs.each { |file| require file }

Spec::Runner.configure do |config|
  config.after(:suite) { Montage::Spec::ProjectHelper.cleanup! }
end
