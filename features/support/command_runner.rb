require 'rbconfig'
require 'tempfile'
require 'open3'

module Flexo
  module Spec
    # Runs flexo commands in a subprocess and reports back on their exit
    # status and output.
    #
    # See spec/flexo/commands/*_spec.rb.
    #
    class CommandRunner < ProjectHelper

      # Path to the Ruby binary.
      RUBY = Pathname.new(Config::CONFIG['bindir']) +
                          Config::CONFIG['ruby_install_name']

      # Path to the flexo executable.
      EXECUTABLE = Pathname.new(__FILE__).dirname.
                      expand_path + '../../bin/flexo'

      attr_reader :status, :stderr, :stdout

      # ----------------------------------------------------------------------

      # Runs the given command in the test directory.
      #
      # @param [String] command
      #   The command to be run.
      #
      # @return [CommandRunner]
      #   Returns self.
      #
      def run(command, &block)
        if command =~ /^flexo(.*)$/
          # Load Rubygems when on <1.9 (there has to be a better way to do
          # this, surely)
          rubygems = RUBY_VERSION < '1.9' ? ' -rubygems' : ''
          command  = "#{RUBY}#{rubygems} #{EXECUTABLE}#{$1} --no-color"
        end

        in_project_dir do
          @stdout, @stderr, @status = Open3.capture3(command)
          @status = @status.exitstatus
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
end # Flexo
