# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{montage}
  s.version = "0.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Anthony Williams"]
  s.date = %q{2010-04-08}
  s.default_executable = %q{montage}
  s.description = %q{Even Rocky had a montage.}
  s.email = %q{hi@antw.me}
  s.executables = ["montage"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.md"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "History.md",
     "LICENSE",
     "README.md",
     "Rakefile",
     "VERSION",
     "bin/montage",
     "lib/montage.rb",
     "lib/montage/commands.rb",
     "lib/montage/commands/generate.rb",
     "lib/montage/commands/init.rb",
     "lib/montage/core_ext.rb",
     "lib/montage/project.rb",
     "lib/montage/sass_builder.rb",
     "lib/montage/source.rb",
     "lib/montage/sprite.rb",
     "lib/montage/templates/montage.yml",
     "lib/montage/templates/sass_mixins.erb",
     "lib/montage/templates/sources/book.png",
     "lib/montage/templates/sources/box-label.png",
     "lib/montage/templates/sources/calculator.png",
     "lib/montage/templates/sources/calendar-month.png",
     "lib/montage/templates/sources/camera.png",
     "lib/montage/templates/sources/eraser.png",
     "lib/montage/version.rb",
     "montage.gemspec",
     "spec/fixtures/custom_dirs/montage.yml",
     "spec/fixtures/default/montage.yml",
     "spec/fixtures/default/public/images/sprites/src/one.png",
     "spec/fixtures/default/public/images/sprites/src/three.png",
     "spec/fixtures/default/public/images/sprites/src/two.png",
     "spec/fixtures/directory_config/config/montage.yml",
     "spec/fixtures/missing_source/montage.yml",
     "spec/fixtures/missing_source_dir/montage.yml",
     "spec/fixtures/root_config/montage.yml",
     "spec/fixtures/root_config/public/images/sprites/src/source_one.png",
     "spec/fixtures/root_config/public/images/sprites/src/source_three.jpg",
     "spec/fixtures/root_config/public/images/sprites/src/source_two",
     "spec/fixtures/sources/hundred.png",
     "spec/fixtures/sources/mammoth.png",
     "spec/fixtures/sources/other.png",
     "spec/fixtures/sources/twenty.png",
     "spec/fixtures/subdirs/montage.yml",
     "spec/fixtures/subdirs/sub/sub/keep",
     "spec/lib/command_runner.rb",
     "spec/lib/fixtures.rb",
     "spec/lib/have_public_method_defined.rb",
     "spec/lib/project_helper.rb",
     "spec/lib/shared_project_specs.rb",
     "spec/lib/shared_sprite_specs.rb",
     "spec/montage/commands/generate_spec.rb",
     "spec/montage/commands/init_spec.rb",
     "spec/montage/core_ext_spec.rb",
     "spec/montage/project_spec.rb",
     "spec/montage/sass_builder_spec.rb",
     "spec/montage/source_spec.rb",
     "spec/montage/spec/have_public_method_defined_spec.rb",
     "spec/montage/sprite_spec.rb",
     "spec/rcov.opts",
     "spec/spec.opts",
     "spec/spec_helper.rb",
     "tasks/spec.rake",
     "tasks/yard.rake"
  ]
  s.has_rdoc = false
  s.homepage = %q{http://github.com/antw/montage}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Montage}
  s.test_files = [
    "spec/lib/command_runner.rb",
     "spec/lib/fixtures.rb",
     "spec/lib/have_public_method_defined.rb",
     "spec/lib/project_helper.rb",
     "spec/lib/shared_project_specs.rb",
     "spec/lib/shared_sprite_specs.rb",
     "spec/montage/commands/generate_spec.rb",
     "spec/montage/commands/init_spec.rb",
     "spec/montage/core_ext_spec.rb",
     "spec/montage/project_spec.rb",
     "spec/montage/sass_builder_spec.rb",
     "spec/montage/source_spec.rb",
     "spec/montage/spec/have_public_method_defined_spec.rb",
     "spec/montage/sprite_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 3.0.0.beta"])
      s.add_runtime_dependency(%q<rmagick>, [">= 2.12"])
      s.add_runtime_dependency(%q<highline>, [">= 1.5"])
      s.add_development_dependency(%q<rspec>, [">= 1.3.0"])
      s.add_development_dependency(%q<cucumber>, [">= 0.6"])
      s.add_development_dependency(%q<open4>, [">= 1.0"])
      s.add_development_dependency(%q<haml>, [">= 3.0.0.beta.1"])
      s.add_development_dependency(%q<yard>, [">= 0.5"])
    else
      s.add_dependency(%q<activesupport>, [">= 3.0.0.beta"])
      s.add_dependency(%q<rmagick>, [">= 2.12"])
      s.add_dependency(%q<highline>, [">= 1.5"])
      s.add_dependency(%q<rspec>, [">= 1.3.0"])
      s.add_dependency(%q<cucumber>, [">= 0.6"])
      s.add_dependency(%q<open4>, [">= 1.0"])
      s.add_dependency(%q<haml>, [">= 3.0.0.beta.1"])
      s.add_dependency(%q<yard>, [">= 0.5"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 3.0.0.beta"])
    s.add_dependency(%q<rmagick>, [">= 2.12"])
    s.add_dependency(%q<highline>, [">= 1.5"])
    s.add_dependency(%q<rspec>, [">= 1.3.0"])
    s.add_dependency(%q<cucumber>, [">= 0.6"])
    s.add_dependency(%q<open4>, [">= 1.0"])
    s.add_dependency(%q<haml>, [">= 3.0.0.beta.1"])
    s.add_dependency(%q<yard>, [">= 0.5"])
  end
end

