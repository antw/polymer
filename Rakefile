require 'rake'
require 'rake/clean'

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'flexo/version'

CLOBBER.include ['pkg', '*.gem', 'doc', 'coverage', 'measurements']
FileList['tasks/**/*.rake'].each { |task| import task }

desc 'Run RSpec examples followed by the Cucumber features'
task :test    => [:spec, :features]
task :default => :test
