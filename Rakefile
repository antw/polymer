require 'rake'
require 'rake/clean'

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'flexo/version'

CLOBBER.include %w( pkg *.gem documentation coverage
                    measurements lib/flexo/man )

# === Helpers ================================================================

require 'date'

def replace_header(head, header_name, value)
  head.sub!(/(\.#{header_name}\s*= ').*'/) { "#{$1}#{value}'" }
end

# === Tasks ==================================================================

# --- Build ------------------------------------------------------------------

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
task :build => [:man, :gemspec] do
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
    reject { |file| file =~ /^(rdoc|pkg|spec|tasks|features|man)/ }.
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

# --- Tests ------------------------------------------------------------------

require 'rspec/core/rake_task'
require 'cucumber/rake/task'

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
end

Cucumber::Rake::Task.new(:features) do |features|
  features.cucumber_opts = '--format pretty --tag ~@pending'
end

desc 'Run RSpec examples followed by the Cucumber features'
task :test    => [:spec, :features]
task :default => :test

# --- Man Pages --------------------------------------------------------------

desc 'Builds the Flexo manual pages'
task :man do
  require 'pathname'

  source_dir = Pathname.new('man')
  dest_dir   = Pathname.new('lib/flexo/man')

  dest_dir.rmtree
  dest_dir.mkpath

  Pathname.glob(source_dir + '*.ronn').each do |source|
    destination = dest_dir + source.basename('.ronn')

    # Create the man page.
    sh "ronn --roff --manual='Flexo Manual' " \
       "--organization='FLEXO #{Flexo::VERSION.upcase}' " \
       "--pipe #{source} > #{destination}"

    # Set man pages to be left-aligned (not justified).
    sh "sed -i '' -e '3i\\\n.ad l\n' #{destination}"

    # Create a text-only version of the man page.
    sh "groff -Wall -mtty-char -mandoc -Tascii " \
       "#{destination} | col -b > #{destination}.txt"
  end
end

# --- YARD -------------------------------------------------------------------

begin
  require 'yard'
  YARD::Rake::YardocTask.new do |doc|
    doc.options << '--no-highlight'
  end
rescue LoadError
  desc 'yard task requires that the yard gem is installed'
  task :yard do
    abort 'YARD is not available. In order to run yard, you must: gem ' \
          'install yard'
  end
end

# --- Console ----------------------------------------------------------------

desc 'Open an irb session preloaded with Flexo'
task :console do
  sh 'irb -I ./lib -rubygems -r ./lib/flexo.rb'
end
