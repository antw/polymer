require 'rake'
require 'rake/clean'

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'polymer/version'

CLOBBER.include %w( pkg *.gem documentation coverage
                    measurements lib/polymer/man )

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

  sh "git commit --allow-empty -a -m 'Release #{Polymer::VERSION}'"
  sh "git tag v#{Polymer::VERSION}"
  sh "git push origin master"
  sh "git push origin v#{Polymer::VERSION}"

  puts "Push to Rubygems.org with"
  puts "  gem push pkg/polymer-#{Polymer::VERSION}.gem"
end

desc 'Builds the gem'
task :build => [:man, :gemspec] do
  sh "mkdir -p pkg"
  sh "gem build polymer.gemspec"
  sh "mv polymer-#{Polymer::VERSION}.gem pkg"
end

desc 'Create a fresh gemspec'
task :gemspec => :validate do
  gemspec_file = File.expand_path('../polymer.gemspec', __FILE__)

  # Read spec file and split out the manifest section.
  spec = File.read(gemspec_file)
  head, manifest, tail = spec.split("  # = MANIFEST =\n")

  # Replace name version and date.
  replace_header head, :name,              'polymer'
  replace_header head, :rubyforge_project, 'polymer'
  replace_header head, :version,            Polymer::VERSION
  replace_header head, :date,               Date.today.to_s

  # Determine file list from git ls-files.
  files = `git ls-files`.
    split("\n").
    sort.
    reject { |file| file =~ /^\./ }.
    reject { |file| file =~ /^(rdoc|pkg|spec|tasks|features|man)/ }

  # Add man pages.
  files += Dir['lib/polymer/man/*']

  # Format list for the gemspec.
  files = files.map { |file| "    #{file}" }.join("\n")

  # Piece file back together and write.
  manifest = "  s.files = %w[\n#{files}\n  ]\n"
  spec = [head, manifest, tail].join("  # = MANIFEST =\n")
  File.open(gemspec_file, 'w') { |io| io.write(spec) }

  puts "Updated #{gemspec_file}"
end

task :validate do
  unless Dir['lib/*'] - %w(lib/polymer.rb lib/polymer)
    puts 'The lib/ directory should only contain a polymer.rb file, and a ' \
         'polymer/ directory'
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
  features.cucumber_opts = '--format progress --tag ~@pending'
end

desc 'Run RSpec examples followed by the Cucumber features'
task :test    => [:spec, :features]
task :default => :test

# --- Man Pages --------------------------------------------------------------

desc 'Builds the Polymer manual pages'
task :man do
  require 'pathname'

  source_dir = Pathname.new('man')
  dest_dir   = Pathname.new('lib/polymer/man')

  dest_dir.rmtree if dest_dir.directory?
  dest_dir.mkpath

  Pathname.glob(source_dir + '*.ronn').each do |source|
    destination = dest_dir + source.basename('.ronn')

    # Create the man page.
    sh "ronn --roff --manual='Polymer Manual' " \
       "--organization='POLYMER #{Polymer::VERSION.upcase}' " \
       "--pipe #{source} > #{destination}"

    # Set man pages to be left-aligned (not justified).
    sh "sed -i '' -e '3i\\\n.ad l\n' #{destination}"

    # Create a text-only version of the man page.
    sh "groff -Wall -mtty-char -mandoc -Tascii " \
       "#{destination} | col -b > #{destination}.txt"
  end
end

desc 'Builds HTML for Github Pages, then publishes'
task :pages do
  # Cheers to rtomayko/ronn/Rakefile
  sh "ronn -5 --manual='Polymer Manual' " \
     "--organization='POLYMER #{Polymer::VERSION.upcase}' " \
     "-s toc -w man/*.ronn"

  puts '-' * 50
  puts 'Rebuilding pages ...'

  verbose(false) do
    rm_rf 'pages'
    push_url = `git remote show origin`.lines.grep(/Push.*URL/).first[/git@.*/]
    sh 'git fetch -q origin'
    sh 'rev=$(git rev-parse origin/gh-pages)'
    sh 'git clone -q -b gh-pages . pages'
    cd 'pages'
    sh 'git reset --hard $rev'
    sh 'rm -f polymer*.html index.html'
    sh 'cp -rp ../man/polymer*.html ../man/index.html ./'
    sh 'git add -u polymer*.html index.html'
    sh 'git commit -m "Rebuild manual."'
    sh "git push #{push_url} gh-pages"
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

desc 'Open an irb session preloaded with Polymer'
task :console do
  sh 'irb -I ./lib -rubygems -r ./lib/polymer.rb'
end

