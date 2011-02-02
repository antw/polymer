# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

Gem::Specification.new do |s|
  s.required_rubygems_version = '>= 1.3.6'

  # The following four lines are automatically updates by the "gemspec"
  # rake task. It it completely safe to edit them, but using the rake task
  # is easier.
  s.name              = 'polymer'
  s.version           = '1.0.0.beta.7'
  s.date              = '2011-02-02'
  s.rubyforge_project = 'polymer'

  # You may safely edit the section below.

  s.platform     = Gem::Platform::RUBY
  s.authors      = ['Anthony Williams']
  s.email        = ['hi@antw.me']
  s.homepage     = 'http://github.com/antw/polymer'
  s.summary      = 'Creates sprites for web applications'
  s.description  = 'Polymer simplifies the creation of sprite images for ' \
                   'web applications, while also generating nifty Sass ' \
                   'mixins. CSS files are available for non-Sass users.'

  s.rdoc_options     = ['--charset=UTF-8']
  s.extra_rdoc_files = %w[History.md LICENSE README.md]

  s.executables  = ['polymer']
  s.require_path = 'lib'

  s.add_runtime_dependency     'chunky_png', '>= 0.12'
  s.add_runtime_dependency     'thor',       '>= 0.14.0'
  s.add_development_dependency 'rspec',      '>= 2.0.0.beta.19'
  s.add_development_dependency 'cucumber',   '>= 0.8.5'
  s.add_development_dependency 'haml',       '>= 3.0.18'

  # The manifest is created by the "gemspec" rake task. Do not edit it
  # directly; your changes will be wiped out when you next run the task.

  # = MANIFEST =
  s.files = %w[
    Gemfile
    History.md
    LICENSE
    README.md
    Rakefile
    bin/polymer
    lib/polymer.rb
    lib/polymer/cache.rb
    lib/polymer/cli.rb
    lib/polymer/css_generator.rb
    lib/polymer/deviant_finder.rb
    lib/polymer/dsl.rb
    lib/polymer/optimisation.rb
    lib/polymer/project.rb
    lib/polymer/sass_generator.rb
    lib/polymer/source.rb
    lib/polymer/sprite.rb
    lib/polymer/templates/polymer.tt
    lib/polymer/templates/sass_mixins.erb
    lib/polymer/templates/sources/one/book.png
    lib/polymer/templates/sources/one/box-label.png
    lib/polymer/templates/sources/one/calculator.png
    lib/polymer/templates/sources/one/calendar-month.png
    lib/polymer/templates/sources/one/camera.png
    lib/polymer/templates/sources/one/eraser.png
    lib/polymer/templates/sources/two/inbox-image.png
    lib/polymer/templates/sources/two/magnet.png
    lib/polymer/templates/sources/two/newspaper.png
    lib/polymer/templates/sources/two/television.png
    lib/polymer/templates/sources/two/wand-hat.png
    lib/polymer/templates/sources/two/wooden-box-label.png
    lib/polymer/version.rb
    polymer.gemspec
    lib/polymer/man/polymer-bond.1
    lib/polymer/man/polymer-bond.1.txt
    lib/polymer/man/polymer-init.1
    lib/polymer/man/polymer-init.1.txt
    lib/polymer/man/polymer-optimise.1
    lib/polymer/man/polymer-optimise.1.txt
    lib/polymer/man/polymer-position.1
    lib/polymer/man/polymer-position.1.txt
    lib/polymer/man/polymer.1
    lib/polymer/man/polymer.1.txt
    lib/polymer/man/polymer.5
    lib/polymer/man/polymer.5.txt
  ]
  # = MANIFEST =

  s.test_files = s.files.select { |path| path =~ /^spec\/.*\.rb/ }
end
