require 'term/ansicolor'

Term::ANSIColor.coloring = ! ARGV.delete('--no-color') && ! ARGV.delete('--no-colour')
Term::ANSIColor.coloring = false if !STDOUT.tty? && !ENV.has_key?("AUTOTEST")

module Montage
  module Commands
    extend self

    # Prints the Montage masthead, introducing the programme, and including
    # the current version number.
    def print_masthead
      $stdout.puts
      $stdout.puts "Montage v#{Montage::VERSION}"
      $stdout.puts "=========#{'=' * Montage::VERSION.length}"
      $stdout.puts
    end

    # Exits immediately, outputting a blank line first.
    def exit(status)
      $stdout.puts
      Kernel.exit(status)
    end

  end # Commands
end # Montage
