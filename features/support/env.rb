require 'forwardable'

# Add spec/ to the load path.
$LOAD_PATH.unshift File.expand_path('../../../spec', __FILE__)

# Loading the spec helper loads all of the test support files, and
# also the Flexo library itself.
require 'spec_helper'

# Cucumber helpers.
require File.expand_path('../command_runner', __FILE__)

# This Cucumber world wraps around the CommandRunner in order to provide
# some useful helper method.
class Flexo::Spec::CucumberWorld
  extend Forwardable

  # Path to the flexo executable.
  EXECUTABLE = Pathname.new(__FILE__).dirname.
                  expand_path + '../../bin/flexo'

  # The CommandRunner instance used by the world to run commands.
  attr_reader :command

  # A list of files whose attributes have been modified.
  attr_reader :chmods

  # Helpers which should be passed through to the command.
  def_delegators :command, :status, :stdout, :stderr

  def initialize
    @command = Flexo::Spec::CommandRunner.new nil
    @chmods  = {}
  end

  # Runs a command.
  #
  # @param [String] to_run
  #   The command to be run, exactly as it would be on the command line.
  # @param [Block] block
  #   Yields the stdin.
  #
  # @return [Boolean]
  #   Returns true if the command exited with zero status, false if non-zero.
  #
  def run(to_run, &block)
    if to_run =~ /^flexo(.*)$/
      to_run = "#{EXECUTABLE}#{$1} --no-color"
    end

    @command.run(to_run, &block)
    @command.status == 0
  end

  def compile_and_escape(string)
    Regexp.compile(Regexp.escape(string))
  end

  def combined_output
    stdout + (stderr == '' ? '' : "\n#{'-'*70}\n#{stderr}")
  end

end # Flexo::Spec::CucumberWorld

World do
  Flexo::Spec::CucumberWorld.new
end

After do
  # Restore the attributes of any files which changed.
  chmods.each { |path, mode| Pathname.new(path).chmod(mode) }
end

# Always clean up temporary project directories once finished.
at_exit do
  Flexo::Spec::ProjectHelper.cleanup!
end
