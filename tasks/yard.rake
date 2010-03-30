begin
  require 'yard'
  YARD::Rake::YardocTask.new do |doc|
    doc.options << '--no-highlight'
  end
rescue LoadError
  task :yard do
    abort 'YARD is not available. In order to run yard, you must: gem ' \
          'install yard'
  end
end
