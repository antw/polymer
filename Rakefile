require 'rake'
require 'rake/clean'

require File.expand_path('../lib/montage/version', __FILE__)

CLOBBER.include ['pkg', '*.gem', 'doc', 'coverage', 'measurements']

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name        = 'ward'
    gem.summary     = 'Ward'
    gem.homepage    = 'http://github.com/antw/montage'
    gem.description = 'Even Rocky had a montage.'

    gem.author      = 'Anthony Williams'
    gem.email       = 'hi@antw.me'

    gem.platform    = Gem::Platform::RUBY
    gem.has_rdoc    = false

    # Dependencies.
    gem.add_dependency 'rmagick', '>= 2.12'

    # Development dependencies.
    gem.add_development_dependency 'rspec', '>= 1.3.0'
    gem.add_development_dependency 'yard',  '>= 0.5'
  end

  Jeweler::GemcutterTasks.new
rescue LoadError
  puts 'Jeweler (or a dependency) not available. Install it with: gem '\
       'install jeweler'
end

FileList['tasks/**/*.rake'].each { |task| import task }
