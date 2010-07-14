begin

  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec) do |spec|
    spec.pattern = 'spec/**/*_spec.rb'
  end

rescue LoadError
  task :spec do
    abort 'rspec is not available. In order to run spec, you must: gem ' \
          'install rspec'
  end
end
