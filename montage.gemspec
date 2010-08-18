# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'montage/version'

Gem::Specification.new do |s|
  s.name        = 'montage'
  s.version     = Montage::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Anthony Williams']
  s.email       = ['hi@antw.me']
  s.homepage    = 'http:/github.com/antw/montage'
  s.summary     = 'Even Rocky had a montage.'
  s.description = 'Montage simplifies the creation of sprite images for ' \
                  'web applications, while also generating nifty Sass ' \
                  'mixins. Sprites have never been so easy.'

  s.required_rubygems_version = '>= 1.3.6'
  s.rubyforge_project         = 'montage'

  s.add_runtime_dependency     'rmagick',            '>= 2.12'
  s.add_runtime_dependency     'highline',           '>= 1.5'
  s.add_development_dependency 'rspec-core',         '>= 2.0.0.beta.12'
  s.add_development_dependency 'rspec-expectations', '>= 2.0.0.beta.12'
  s.add_development_dependency 'rspec-mocks',        '>= 2.0.0.beta.12'
  s.add_development_dependency 'open4',              '>= 1.0'
  s.add_development_dependency 'haml',               '>= 3.0.0'
  s.add_development_dependency 'yard',               '>= 0.5'

  s.files = Dir.glob("{bin,lib}/**/*") +
    %w(.document History.md LICENSE README.md)

  s.executables  = ['montage']
  s.require_path = 'lib'

end

