require 'rbconfig'
require 'tempfile'
require 'open4'

require Pathname(__FILE__).dirname + 'project_helper'

module Montage
  module Spec
    # Runs montage commands in a subprocess and reports back on their exit
    # status and output.
    #
    # See spec/montage/commands/*_spec.rb.
    #
    class CommandRunner < ProjectHelper

      # Path to the Ruby binary.
      RUBY = Pathname.new(Config::CONFIG['bindir']) +
                          Config::CONFIG['ruby_install_name']

      # Path to the montage executable.
      EXECUTABLE = Pathname.new(__FILE__).dirname.
                      expand_path + '../../bin/montage'

      attr_reader :status, :stderr, :stdout

      # ----------------------------------------------------------------------

      # Creates a new CommandRunner instance.
      #
      # @param [String] command
      #   The command to be run (exactly as it would be on the command-line).
      #
      def initialize(command)
        super()

        if command =~ /^montage(.*)$/
          command = "#{RUBY} -rubygems #{EXECUTABLE}#{$1} --no-color"
        end

        @command = command
      end

      # Runs the command in the test directory.
      #
      # @return [CommandRunner]
      #   Returns self.
      #
      def run!
        @status, @stderr, @stdout = nil, nil, nil

        in_project_dir do
          @status = Open4.popen4(@command.to_s) do |_, _, stdout, stderr|
            @stdout = stdout.read
            @stderr = stderr.read
          end.exitstatus
        end

        self
      end

      # Returns if the latest command completed successfully.
      #
      # @return [Boolean]
      #
      def success?
        @status == 0
      end

      # Returns if the latest command failed to complete successfully.
      #
      # @return [Boolean]
      #
      def failure?
        not success?
      end

      # Returns the dimensions of a generated sprite image.
      #
      # @param [String] name
      #   The name of the sprite file.
      #
      # @return [Array<Integer, Integer>]
      #
      def dimensions_of(name)
        info = Magick::Image.ping path_to_sprite(name)
        [info.first.columns, info.first.rows]
      end

      private # --------------------------------------------------------------

      # Temporarily switches to the test directory for running commands.
      def in_project_dir(&blk)
        Dir.chdir(project_dir, &blk)
      end

    end # CommandRunner
  end # Spec
end # Montage
