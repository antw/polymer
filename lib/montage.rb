require 'yaml'
require 'pathname'
require 'fileutils'
require 'digest'

# Gems.
require 'active_support/ordered_hash'
require 'rmagick'

# On with the library...
require 'montage/core_ext'
require 'montage/project'
require 'montage/source'
require 'montage/sprite'
require 'montage/version'

module Montage
  # Generic exception for all Montage exception classes.
  MontageError = Class.new(StandardError)

  # Raised when a project directory couldn't be found.
  MissingProject = Class.new(MontageError)

  # Raised when a creating a new project in an existing project directory.
  ProjectExists = Class.new(MontageError)

  # Raised when a sprite set expects a source image, but none could be found.
  MissingSource = Class.new(MontageError)
end
