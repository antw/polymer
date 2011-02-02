require 'digest/sha2'
require 'erb'
require 'pathname'
require 'yaml'

# Gems.

begin
  require 'oily_png' # Load the C version of ChunkyPNG when available.
rescue LoadError
  require 'chunky_png' # Fall back to pure-Ruby.
end

# On with the library...
require 'polymer/cache'
require 'polymer/css_generator'
require 'polymer/deviant_finder'
require 'polymer/dsl'
require 'polymer/optimisation'
require 'polymer/project'
require 'polymer/sass_generator'
require 'polymer/source'
require 'polymer/sprite'
require 'polymer/version'

module Polymer
  # Generic exception for all Polymer exception classes.
  PolymerError = Class.new(StandardError)

  # Raised when a project directory couldn't be found.
  MissingProject = Class.new(PolymerError)

  # Raised when a creating a new project in an existing project directory.
  ProjectExists = Class.new(PolymerError)

  # Raised when a sprite set expects a source image, but none could be found.
  MissingSource = Class.new(PolymerError)

  # Raised when a sprite can't be saved due to incorrect permissions.
  TargetNotWritable = Class.new(PolymerError)

  # Raised when an error happens using the DSL.
  DslError = Class.new(PolymerError)

  # Raised when a sprite definition is lacking a { source => sprite } pair.
  MissingMap = Class.new(DslError)

  # Raised when a sprite defintion doesn't include a name.
  MissingName = Class.new(DslError)

  # Raised when sprite is defined with a name which has already been used.
  DuplicateName = Class.new(DslError)

  # A utility method; given a string, removes leading and trailing whitespace
  # from each line, then joins all the lines into one.
  #
  # @param  [String] str A string
  # @return [String]
  #
  def self.compress_lines(str)
    str.split($/).map { |line| line.strip }.join(' ')
  end
end
