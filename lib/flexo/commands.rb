module Flexo
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
    # Returns any unparsed command-line arguments.
    #
    def parse_options!(argv)
      HighLine.use_color = false if !STDOUT.tty? && !ENV.has_key?("AUTOTEST")

      OptionParser.new do |opts|
        opts.banner = "Usage: flexo [config file path] [options]"

        opts.on('-c', '--[no-]color', '--[no-]colour',
                'Enables and disables colour output.') do |color|
          HighLine.use_color = color
        end

        opts.on('-f', '--force',
                'Regenerate sprites even if no changes have been made.') do
          Flexo::Commands.config[:force] = true
        end

        # opts.on('-q', '--quiet',
        #         'Tell Flexo to shut up. No messages sent to STDOUT.') do
        #   Flexo::Commands.config[:quiet] = true
        # end

        opts.on_tail("-h", "--help", "Shows this message.") do
          say BLANK
          say opts.to_s
          exit
        end

        opts.on_tail("--version", "Print the current Flexo version.") do
          say BLANK
          say "Flexo v#{Flexo::VERSION}"
          exit
        end
      end.parse!(argv)

      argv
    end

    # Exits immediately, outputting a blank line first.
    def exit(status = 0)
      say BLANK
      Kernel.exit(status)
    end

  end # Commands
end # Flexo
