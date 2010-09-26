require 'rbconfig'
require 'tempfile'

module Polymer
  module Spec
    # Runs polymer commands in a subprocess and reports back on their exit
    # status and output.
    #
    # See spec/polymer/commands/*_spec.rb.
    #
    class CommandRunner < ProjectHelper

      # Path to the Ruby binary.
      RUBY = Pathname.new(Config::CONFIG['bindir']) +
                          Config::CONFIG['ruby_install_name']

      # Path to the polymer executable.
      EXECUTABLE = Pathname.new(__FILE__).dirname.
                      expand_path + '../../bin/polymer'

      attr_reader :status, :stderr, :stdout

      # ----------------------------------------------------------------------

      # Runs the given command in the test directory.
      #
      # @param [String] command
      #   The command to be run.
      # @param [String] dir
      #   An optional sub-directory in which to run the command.
      #
      # @return [CommandRunner]
      #   Returns self.
      #
      def run(command, dir = '', &block)
        if command =~ /^polymer(.*)$/
          # Load Rubygems when on <1.9 (there has to be a better way to do
          # this, surely)
          rubygems = RUBY_VERSION < '1.9' ? ' -rubygems' : ''
          command  = "#{RUBY}#{rubygems} #{EXECUTABLE}#{$1} --no-color"
        end

        in_project_dir(dir) do
          if RUBY_VERSION < '1.9'
            # Sigh.
            stderr_file = Tempfile.new('stderr')
            stderr_file.close

            IO.popen("#{command} 2> #{stderr_file.path}", 'r') do |io|
              @stdout = io.read
            end

            @status = $?.exitstatus
            @stderr = File.read(stderr_file.path)
          else
            require 'open3'
            @stdout, @stderr, @status = Open3.capture3(command)
            @status = @status.exitstatus
          end
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

    end # CommandRunner
  end # Spec
end # Polymer
