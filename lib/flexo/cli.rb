require 'fileutils'
require 'thor'

module Flexo
  class CLI < Thor

    include Thor::Actions

    # init -------------------------------------------------------------------
    class_option 'no-color', :type => :boolean, :default => false,
      :desc => 'Disable colours in output'

    def initialize(*args)
      super
      self.shell = Thor::Shell::Basic.new if options['no-color']
    end

    # --- init ---------------------------------------------------------------

    desc 'init', 'Generates the files necessary to use Flexo'

    long_desc <<-DESC
      In order to use Flexo, a .flexo configuration file must be created. The
      init task creates a sample configuration, and also adds a couple of
      example source images to demonstrate how to use Flexo to create your own
      sprite images.
    DESC

    # The directory, relative to the project root, where the genrated sprite
    # files are to be saved.
    method_option :sprites, :type => :string, :default => 'public/images',
      :desc => 'Default location to which generated sprites are saved'

    # The directory in which source files are found.
    method_option :sources, :type => :string, :default => '<sprites>/sprites',
      :desc => 'Default location of source images'

    # Disable copying example sources.
    method_option 'no-examples', :type => :boolean, :default => false,
      :desc => "Disables copying of example source files"

    def init
      if File.exists?('.flexo')
        say 'A .flexo file already exists in this directory.', :red
        exit 1
      end

      project_dir = Pathname.new(Dir.pwd)

      config = {
        :sprites => options[:sprites],
        :sources => options[:sources].gsub(/<sprites>/, options[:sprites])
      }

      template 'flexo.tt', project_dir + '.flexo', config

      unless options['no-examples']
        directory 'sources',  project_dir + config[:sources]
      end

      say_status '', '-------------------------'
      say_status '', 'Your project was created!'
    end

    # ------------------------------------------------------------------------

    def self.source_root
      File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
    end

  end # CLI
end # Flexo
