# Much of this file is from the MIT licensed rakegem by Tom Preston-Werner:
# -- http://github.com/mojombo/rakegem

require 'date'

# Helpers ====================================================================

def replace_header(head, header_name, value)
  head.sub!(/(\.#{header_name}\s*= ').*'/) { "#{$1}#{value}'" }
end

# Tasks ======================================================================

desc 'Build the gem, and push to Github'
task :release => :build do
  unless system('git branch') =~ /^\* master$/
    puts "You must be on the master branch to release!"
    exit!
  end

  sh "git commit --allow-empty -a -m 'Release #{Flexo::VERSION}'"
  sh "git tag v#{Flexo::VERSION}"
  sh "git push origin master"
  sh "git push origin v#{Flexo::VERSION}"

  puts "Push to Rubygems.org with"
  puts "  gem push pkg/flexo-#{Flexo::VERSION}.gem"
end

desc 'Builds the gem'
task :build => :gemspec do
  sh "mkdir -p pkg"
  sh "gem build flexo.gemspec"
  sh "mv flexo-#{Flexo::VERSION}.gem pkg"
end

desc 'Create a fresh gemspec'
task :gemspec => :validate do
  gemspec_file = File.expand_path('../../flexo.gemspec', __FILE__)

  # Read spec file and split out the manifest section.
  spec = File.read(gemspec_file)
  head, manifest, tail = spec.split("  # = MANIFEST =\n")

  # Replace name version and date.
  replace_header head, :name,              'flexo'
  replace_header head, :rubyforge_project, 'flexo'
  replace_header head, :version,            Flexo::VERSION
  replace_header head, :date,               Date.today.to_s

  # Determine file list from git ls-files.
  files = `git ls-files`.
    split("\n").
    sort.
    reject { |file| file =~ /^\./ }.
    reject { |file| file =~ /^(rdoc|pkg|spec|tasks|features)/ }.
    map    { |file| "    #{file}" }.
    join("\n")

  # Piece file back together and write.
  manifest = "  s.files = %w[\n#{files}\n  ]\n"
  spec = [head, manifest, tail].join("  # = MANIFEST =\n")
  File.open(gemspec_file, 'w') { |io| io.write(spec) }

  puts "Updated #{gemspec_file}"
end

task :validate do
  unless Dir['lib/*'] - %w(lib/flexo.rb lib/flexo)
    puts 'The lib/ directory should only contain a flexo.rb file, and a ' \
         'flexo/ directory'
    exit!
  end

  unless Dir['VERSION*'].empty?
    puts 'A VERSION file at root level violates Gem best practices'
    exit!
  end
end
