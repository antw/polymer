require 'yaml'
require 'pathname'
require 'fileutils'

# On with the library...
require 'montage/project'
require 'montage/version'

module Montage
  # Generic exception for all Montage exception classes.
  MontageError = Class.new(StandardError)

  # Raised when a project directory couldn't be found.
  MissingProject = Class.new(MontageError)

  # Raised when a creating a new project in an existing project directory.
  ProjectExists = Class.new(MontageError)
end
