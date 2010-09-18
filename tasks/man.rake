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
       "--organization='Flexo #{Flexo::VERSION.upcase}' " \
       "--pipe #{source} > #{destination}"

    # Set man pages to be left-aligned (not justified).
    sh "sed -i '' -e '3i\\\n.ad l\n' #{destination}"

    # Create a text-only version of the man page.
    sh "groff -Wall -mtty-char -mandoc -Tascii " \
       "#{destination} | col -b > #{destination}.txt"
  end
end
