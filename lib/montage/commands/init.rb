module Montage
  module Commands
    # Creates a new project.
    class Init
      extend Commands
      extend Term::ANSIColor

      # Creates a new project in the current directory.
      #
      # @param [Array] argv
      #   The arguments given on the command line.
      #
      def self.run(argv)
        Montage::Project.init(Dir.pwd)
        $stdout.puts green("Your project was created")
      rescue Montage::ProjectExists => e
        if e.message.match(/`(.*)'$/)[1] == Dir.pwd
          $stdout.puts red(
            "A Montage project already exists in the current directory")
        else
          $stdout.puts red(e.message.unindent)
        end

        exit(1)
      end

    end # Init
  end # Commands
end # Montage
