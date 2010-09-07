desc 'Open an irb session preloaded with Flexo'
task :console do
  sh 'irb -I ./lib -rubygems -r ./lib/flexo.rb'
end
