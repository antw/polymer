require 'highline/import'

HighLine.use_color = ! ARGV.delete('--no-color') && ! ARGV.delete('--no-colour')
HighLine.use_color = false if !STDOUT.tty? && !ENV.has_key?("AUTOTEST")

module Kernel
  def_delegators :$terminal, :color
end

module Montage
  module Commands
    BLANK = "\n".freeze

    extend self

    # Prints the Montage masthead, introducing the programme, and including
    # the current version number.
    def print_masthead
      say BLANK
      say "Montage v#{Montage::VERSION}"
      say "=========#{'=' * Montage::VERSION.length}"
      say BLANK
    end

    # Exits immediately, outputting a blank line first.
    def exit(status)
      say BLANK
      Kernel.exit(status)
    end

  end # Commands
end # Montage
