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

    # --- generate -----------------------------------------------------------

    desc 'generate [SPRITES]', 'Creates your sprites'

    long_desc <<-DESC
      The generate task reads your project configuration and creates your
      shiny new sprites. If enabled, CSS and/or SCSS will also be written so
      as to make working with your sprites a little easier.

      You may specify exactly which sprites you want generated, otherwise
      Flexo will generate all sprites defined in your config file. Any sprite
      which has not changed since you last ran this command will not be
      re-generated unless you pass the --force option.
    DESC

    method_option :force, :type => :boolean, :default => false,
      :desc => 'Re-generates sprites whose sources have not changed'

    method_option :fast, :type => :boolean, :default => false,
      :desc => "Skip optimisation of images after they are generated"

    def generate(*sprites)
      project = Flexo::Project.find(Dir.pwd)

      cache = project.paths.cache.file? ?
        YAML.load_file(project.paths.cache) : {}

      # Determine which sprites we'll be working on.
      sprites = project.sprites.select do |sprite|
        if sprites.empty? or sprites.include?(sprite.name)
          # The user specified no sprites, or this sprite was requested.
          if (digest = sprite.digest) != cache[sprite.name] or
                options[:force] or not sprite.save_path.file?
            # Digest is different, user is forcing update or sprite file
            # has been deleted.
            cache[sprite.name] = digest
          end
        end
      end

      return if sprites.empty? # Try to exit early. TODO Say something.

      # Get on with it.
      sprites.each do |sprite|
        process Processors::RMagick,  sprite
        #process Processors::Optimise, sprite.save_path unless options[:fast]
      end

      # Stylesheets.
      #process Processors::SCSS,       project
      #process Processors::CSS,        project

      # Find sprites with deviant-width sources.
      sprites.each do |sprite|
        process Processors::Deviants, sprite
      end

      # Finish by writing the new cache.
      File.open(project.paths.cache, 'w') do |cache_file|
        cache_file.puts YAML.dump(cache)
      end

    rescue Flexo::MissingProject
      say <<-ERROR.compress_lines, :red
        Couldn't find a Flexo project in the current directory, or any of the
        parent directories. Run "flexo init" if you want to create a new
        project here.
      ERROR
      exit 1

    rescue Flexo::MissingSource, Flexo::TargetNotWritable => e
      say e.message.compress_lines, :red
      exit 1
    end

    # --- version ------------------------------------------------------------

    desc 'version', "Shows the version of Flexo you're using"
    map '--version' => :version

    def version
      say "Flexo #{Flexo::VERSION}"
    end

    private # ----------------------------------------------------------------

    # Given a processor class, runs it with the second argument as the
    # paramter to Processor.process. Handles callbacks where used.
    #
    # @param [Class, Object] processor
    #   The Flexo::Processor to be called.
    # @param [Object] thing
    #   The "thing" being processed.
    #
    def process(processor, thing)
      processor_message :before, processor, thing
      processor_message :after,  processor, thing, processor.process(thing)
    end

    # Runs a callback method on a given processor. If the method doesn't exist
    # nothing happens. As long as the method doesn't return nil, +say+ or
    # +say_status+ will be called with the output.
    #
    def processor_message(callback, processor, thing, *args)
      method = :"format_#{callback}_message"

      if processor.respond_to?(method) and
            message = processor.send(method, thing, *args)
        message.length == 3 ? say_status(*message) : say(*message)
      end
    end

    # ------------------------------------------------------------------------

    def self.source_root
      File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
    end

  end # CLI
end # Flexo
