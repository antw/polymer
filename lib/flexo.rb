require 'digest/sha2'
require 'erb'
require 'pathname'
require 'yaml'

# Gems.
require 'rmagick'

# On with the library...
require 'flexo/core_ext'
require 'flexo/css_generator'
require 'flexo/deviant_finder'
require 'flexo/dsl'
require 'flexo/optimisation'
require 'flexo/project'
require 'flexo/sass_generator'
require 'flexo/source'
require 'flexo/sprite'
require 'flexo/sprite_definition'
require 'flexo/version'

module Flexo
  # Generic exception for all Flexo exception classes.
  FlexoError = Class.new(StandardError)

  # Raised when a project directory couldn't be found.
  MissingProject = Class.new(FlexoError)

  # Raised when a creating a new project in an existing project directory.
  ProjectExists = Class.new(FlexoError)

  # Raised when a sprite set expects a source image, but none could be found.
  MissingSource = Class.new(FlexoError)

  # Raised when a sprite can't be saved due to incorrect permissions.
  TargetNotWritable = Class.new(FlexoError)

  # Raised when a sprite definition is lacking a { source => sprite } pair.
  MissingMap = Class.new(FlexoError)

  # Raised when a sprite defintion doesn't include a name.
  MissingName = Class.new(FlexoError)

  # Raised when a sprite defines a :name path segment, and a name option.
  DuplicateName = Class.new(FlexoError)

  # Raised when a sprite definition doesn't have a to option.
  MissingTo = Class.new(FlexoError)
end
