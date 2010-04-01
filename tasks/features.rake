begin
  require 'cucumber/rake/task'

  Cucumber::Rake::Task.new(:features) do |features|
    features.cucumber_opts = '--format progress --tag ~@pending'
  end

  task :features => :check_dependencies

rescue LoadError
  task :features do
    abort "Cucumber is not available. In order to run features, you must: " \
          "gem install cucumber"
  end
end
