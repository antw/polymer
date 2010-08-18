task :build do
  system "gem build montage.gemspec"
end

task :release => :build do
  system "gem push montage-#{Montage::VERSION}"
end

