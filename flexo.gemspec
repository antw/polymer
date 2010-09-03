# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

Gem::Specification.new do |s|
  s.required_rubygems_version = '>= 1.3.6'

  # The following four lines are automatically updates by the "gemspec"
  # rake task. It it completely safe to edit them, but using the rake task
  # is easier.
  s.name              = 'flexo'
  s.version           = '0.4.0'
  s.date              = '2010-07-14'
  s.rubyforge_project = 'flexo'

  # You may safely edit the section below.

  s.platform     = Gem::Platform::RUBY
  s.authors      = ['Anthony Williams']
  s.email        = ['hi@antw.me']
  s.homepage     = 'http:/github.com/antw/flexo'
  s.summary      = 'Creates sprites for web applications'
  s.description  = 'Flexo simplifies the creation of sprite images for ' \
                   'web applications, while also generating nifty Sass ' \
                   'mixins. CSS files are available for non-Sass users,' \
                   'along with a directory-watcher and Rack middleware ' \
                   'to make development a breeze.'

  s.rdoc_options     = ['--charset=UTF-8']
  s.extra_rdoc_files = %w[History.md LICENSE README.md]

  s.executables  = ['flexo']
  s.require_path = 'lib'

  s.add_runtime_dependency     'rmagick',            '>= 2.12'
  s.add_runtime_dependency     'highline',           '>= 1.5'
  s.add_development_dependency 'rspec-core',         '>= 2.0.0.beta.12'
  s.add_development_dependency 'rspec-expectations', '>= 2.0.0.beta.12'
  s.add_development_dependency 'rspec-mocks',        '>= 2.0.0.beta.12'
  s.add_development_dependency 'cucumber',           '>= 0.8.5'
  s.add_development_dependency 'open4',              '>= 1.0'
  s.add_development_dependency 'haml',               '>= 3.0.0'

  # The manifest is created by the "gemspec" rake task. Do not edit it
  # directly; you changes will be wiped out when you next run the task.

  # = MANIFEST =
  s.files = %w[
    History.md
    LICENSE
    README.md
    Rakefile
    bin/montage
    lib/montage.rb
    lib/montage/commands.rb
    lib/montage/commands/generate.rb
    lib/montage/commands/init.rb
    lib/montage/core_ext.rb
    lib/montage/project.rb
    lib/montage/sass_builder.rb
    lib/montage/source.rb
    lib/montage/sprite.rb
    lib/montage/sprite_definition.rb
    lib/montage/templates/montage.yml
    lib/montage/templates/sass_mixins.erb
    lib/montage/templates/sources/one/book.png
    lib/montage/templates/sources/one/box-label.png
    lib/montage/templates/sources/one/calculator.png
    lib/montage/templates/sources/one/calendar-month.png
    lib/montage/templates/sources/one/camera.png
    lib/montage/templates/sources/one/eraser.png
    lib/montage/templates/sources/two/inbox-image.png
    lib/montage/templates/sources/two/magnet.png
    lib/montage/templates/sources/two/newspaper.png
    lib/montage/templates/sources/two/television.png
    lib/montage/templates/sources/two/wand-hat.png
    lib/montage/templates/sources/two/wooden-box-label.png
    lib/montage/version.rb
    montage.gemspec
  ]
  # = MANIFEST =

  s.test_files = s.files.select { |path| path =~ /^spec\/.*\.rb/ }
end

