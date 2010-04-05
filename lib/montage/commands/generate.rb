module Montage
  module Commands
    # Generates sprites for a project.
    class Generate
      extend Commands
      extend Term::ANSIColor

      # Given a project, generates sprites.
      #
      # @param [Array] argv
      #   The arguments given on the command line.
      #
      def self.run(argv)
        Montage::Project.find(Dir.pwd).sprites.each do |sprite|
          $stdout.print "#{sprite.name}: "
          sprite.write
          $stdout.puts green("Generated")
        end

      rescue Montage::MissingProject
        $stdout.puts red(<<-ERROR)
          Couldn't find a Montage project in the current directory. If
          you want to create a new project here, run `montage init'.
        ERROR

        exit(1)

      rescue Montage::MissingSource, Montage::TargetNotWritable => e
        $stdout.puts
        $stdout.puts
        $stdout.puts red(e.message)

        exit(1)
      end

    end # Generate
  end # Commands
end # Montage
