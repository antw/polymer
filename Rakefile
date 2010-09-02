require 'rake'
require 'rake/clean'

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'montage/version'

CLOBBER.include ['pkg', '*.gem', 'doc', 'coverage', 'measurements']
FileList['tasks/**/*.rake'].each { |task| import task }
