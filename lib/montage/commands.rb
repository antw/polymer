module Montage
  module Commands
    extend self

    # A blank line; HighLine doesn't allow calling +say+ without an argument.
    BLANK = "\n".freeze

    # Returns a configuration hash, containing options defined on the
    # command-line.
    #
    # @return [Hash]
    #
    def config
      @config ||= { :force => false, :quiet => false }
    end

    # Uses OptParse to parse command-line arguments.
    #
    def parse_options!(argv)
      HighLine.use_color = false if !STDOUT.tty? && !ENV.has_key?("AUTOTEST")

      OptionParser.new do |opts|
        opts.banner = "Usage: montage [config file path] [options]"

        opts.on('-c', '--[no-]color', '--[no-]colour',
                'Enables and disables colour output.') do |color|
          HighLine.use_color = color
        end

        opts.on('-f', '--force',
                'Regenerate sprites even if no changes have been made.') do
          Montage::Commands.config[:force] = true
        end

        # opts.on('-q', '--quiet',
        #         'Tell Montage to shut up. No messages sent to STDOUT.') do
        #   Montage::Commands.config[:quiet] = true
        # end

        opts.on_tail("-h", "--help", "Shows this message.") do
          say BLANK
          say opts.to_s
          exit
        end

        opts.on_tail("--version", "Print the current Montage version.") do
          say BLANK
          say "Montage v#{Montage::VERSION}"
          exit
        end
      end.parse!(argv)

      Montage::Commands.config
    end

    # Prints the Montage masthead, introducing the programme, and including
    # the current version number.
    def print_masthead
      say BLANK
      say "Montage v#{Montage::VERSION}"
      say "=========#{'=' * Montage::VERSION.length}"
      say BLANK
    end

    # Exits immediately, outputting a blank line first.
    def exit(status = 0)
      say BLANK
      Kernel.exit(status)
    end

  end # Commands
end # Montage
