require 'support/project_helper'

module Polymer::Spec
  # A wrapper around ProjectHelper which exposes most of it's methods to
  # RSpec, so we don't constantly have to use +@helper.something+ ...
  module Helper

    # Default options for the helper.
    DEFAULTS = { :sources => 'sources', :sprites => 'sprites' }

    # Fires up the ProjectHelper with the given settings.
    #
    # @param [Hash] options
    #   Options for customising the helper.
    #
    # @option options [String] :sources
    #   Path, relative to the project directory, at which sources are
    #   to be written.
    # @option options [String] :sprites
    #   Path, relative to the project directory, at which sprites are
    #   expected.
    #
    def use_helper!(options = DEFAULTS)
      @helper = Polymer::Spec::ProjectHelper.new

      @helper.sources_path = options[:sources]
      @helper.sprites_path = options[:sprites]

      @helper.write_simple_config

      @helper
    end

    (Polymer::Spec::ProjectHelper.public_instance_methods -
     Object.public_instance_methods).each do |method|

      if method.to_s =~ /=$/
        class_eval <<-RUBY
          def #{method}(value)                # def write=(value)
            @helper.#{method} value           #   @helper.write= value
          end                                 # end
        RUBY
      else
        class_eval <<-RUBY
          def #{method}(*args, &block)        # def write_image(*args, &block)
            @helper.#{method}(*args, &block)  #   @helper.write(*args, &block)
          end                                 # end
        RUBY
      end

    end

  end # Helper
end # Polymer::Spec
