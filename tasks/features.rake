begin

  require 'cucumber/rake/task'

  Cucumber::Rake::Task.new(:features) do |features|
    features.cucumber_opts = '--format progress --tag ~@pending'
  end

rescue LoadError
  desc 'features task requires that cucumber and aruba gems are installed'
  task :features do
    abort 'cucumber and/or aruba are not availble. In order to run ' \
          'features, you must: gem install cucumber aruba'
  end
end
