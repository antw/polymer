require 'rake'
require 'rake/clean'

require File.expand_path('../lib/montage/version', __FILE__)

CLOBBER.include ['pkg', '*.gem', 'doc', 'coverage', 'measurements']

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name        = 'montage'
    gem.summary     = 'Montage'
    gem.homepage    = 'http://github.com/antw/montage'
    gem.description = 'Even Rocky had a montage.'

    gem.author      = 'Anthony Williams'
    gem.email       = 'hi@antw.me'

    gem.platform    = Gem::Platform::RUBY
    gem.has_rdoc    = false

    # Dependencies.
    gem.add_dependency 'rmagick',  '>= 2.12'
    gem.add_dependency 'highline', '>= 1.5'

    # Development dependencies.
    gem.add_development_dependency 'rspec-core',         '>= 2.0.0.beta.12'
    gem.add_development_dependency 'rspec-expectations', '>= 2.0.0.beta.12'
    gem.add_development_dependency 'rspec-mocks',        '>= 2.0.0.beta.12'

    gem.add_development_dependency 'open4', '>= 1.0'
    gem.add_development_dependency 'haml',  '>= 3.0.0.beta.1'
    gem.add_development_dependency 'yard',  '>= 0.5'
  end

  Jeweler::GemcutterTasks.new
rescue LoadError
  puts 'Jeweler (or a dependency) not available. Install it with: gem '\
       'install jeweler'
end

FileList['tasks/**/*.rake'].each { |task| import task }
