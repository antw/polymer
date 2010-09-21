require 'fileutils'
require 'thor'

module Flexo
  class CLI < Thor

    include Thor::Actions

    class_option 'no-color', :type => :boolean, :default => false,
      :desc => 'Disable colours in output'

    def initialize(*args)
      super
      self.shell = Thor::Shell::Basic.new if options['no-color']
    end


    # --- help ---------------------------------------------------------------

    # Provides customised help information using the man pages.
    # Nod-of-the-hat to Bundler.
    def help(command = nil)
      page_map = {
        # Main manual page.
        nil        => 'flexo.1',
        'flexo'    => 'flexo.1',

        # Sub-commands.
        'init'     => 'flexo-init.1',
        'generate' => 'flexo-generate.1',
        'optimise' => 'flexo-optimise.1',
        'optimize' => 'flexo-optimise.1',
        'position' => 'flexo-position.1',

        # Configuration format.
        'flexo(5)' => 'flexo.5',
        'flexo.5'  => 'flexo.5',
        '.flexo'   => 'flexo.5',
        'flexo.rb' => 'flexo.5',
        'config'   => 'flexo.5'
      }

      if page_map.has_key?(command)
        root = File.expand_path('../man', __FILE__)

        groff = 'groff -Wall -mtty-char -mandoc -Tascii'
        pager = ENV['MANPAGER'] || ENV['PAGER'] || 'more'

        Kernel.exec "#{groff} #{root}/#{page_map[command]} | #{pager}"
      else
        super
      end
    end

    # --- init ---------------------------------------------------------------

    desc 'init', 'Creates a new Flexo project in the current directory'

    long_desc <<-DESC
      In order to use Flexo, a .flexo configuration file must be created. The
      init task creates a sample configuration, and also adds a couple of
      example source images to demonstrate how to use Flexo to create your own
      sprite images.
    DESC

    method_option :sprites, :type => :string, :default => 'public/images',
      :desc => 'Default location to which generated sprites are saved'

    method_option :sources, :type => :string, :default => '<sprites>/sprites',
      :desc => 'Default location of source images'

    method_option 'no-examples', :type => :boolean, :default => false,
      :desc => "Disables copying of example source files"

    method_option :windows, :type => :boolean, :default => false,
      :desc => 'Create flexo.rb instead of .flexo for easier editing on ' \
               'Windows systems.'

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

      filename = options[:windows] ? 'flexo.rb' : '.flexo'
      template 'flexo.tt', project_dir + filename, config

      unless options['no-examples']
        directory 'sources',  project_dir + config[:sources]
      end

      say_status '', '-------------------------'
      say_status '', 'Your project was created!'
    end

    # --- generate -----------------------------------------------------------

    desc 'generate [SPRITES]',
      'Creates the sprites specified by your .flexo or flexo.rb file'

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
      project = find_project!

      cache = project.cache.file? ? YAML.load_file(project.cache) : {}

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
        next unless sprite.save

        say_status('generated', sprite.name, :green)

        unless options[:fast]
          say "  optimising  #{sprite.name} ... "
          before = sprite.save_path.size

          reduction = Flexo::Optimisation.optimise_file(sprite.save_path)

          if reduction > 0
            saved = '- saved %.2fkb (%.1f' %
              [reduction.to_f / 1024, (reduction.to_f / before) * 100]
            say_status "\r\e[0K   optimised", "#{sprite.name} #{saved}%)", :green
          else
            print "\r\e[0K"
          end
        end
      end

      # Stylesheets.
      if SassGenerator.generate(project)
        say_status('written', 'Sass mixin', :green)
      end

      #process Processors::CSS,        project

      # Find sprites with deviant-width sources.
      sprites.each do |sprite|
        if deviants = DeviantFinder.find_deviants(sprite)
          say DeviantFinder.format_ui_message(sprite, deviants)
        end
      end

      # Clean up the cache, removing sprites which no longer exist.
      sprite_names = project.sprites.map { |sprite| sprite.name }
      cache.reject! { |key, _| not sprite_names.include?(key) }

      # Finish by writing the new cache.
      File.open(project.cache, 'w') do |cache_file|
        cache_file.puts YAML.dump(cache)
      end

    rescue Flexo::MissingSource, Flexo::TargetNotWritable => e
      say e.message.compress_lines, :red
      exit 1
    end


    # --- optimise -----------------------------------------------------------

    desc 'optimise PATHS', 'Optimises PNG images at the given PATHS'

    long_desc <<-DESC
      Given a path to an image (or multiple images), runs Flexo's optimisers
      on the image. Requires that the paths be images to PNG files. Image
      paths are relative to the current working directory.
    DESC

    def optimise(*paths)
      dir = Pathname.new(Dir.pwd)
      paths = paths.map { |path| dir + path }

      paths.each do |path|
        fpath = path.relative_path_from(dir).to_s

        # Ensure the file is a PNG.
        unless path.to_s =~ /\.png/
          say_status 'skipped', "#{fpath} - not a PNG", :yellow
          next
        end

        before = path.size
        say "  optimising  #{fpath} "
        reduction = Flexo::Optimisation.optimise_file(path)

        if reduction > 0
          saved = '- saved %.2fkb (%.1f' %
            [reduction.to_f / 1024, (reduction.to_f / before) * 100]
          say_status "\r\e[0K   optimised", "#{fpath} #{saved}%)", :green
        else
          say_status "\r\e[0K   optimised", "#{fpath} - no savings", :green
        end
      end
    end

    # --- position -----------------------------------------------------------

    desc 'position SOURCE', 'Shows the position of a source within a sprite'

    long_desc <<-DESC
      The position task shows you the position of a source image within a
      sprite and also shows the appropriate CSS statement for the source
      should you wish to create your own CSS files.

      You may supply the name of a source image; if a source image with the
      same name exists in multiple sprites, the positions of each of them will
      be shown to you. If you want a particular source, you may instead
      provide a "sprite/source" pair.
    DESC

    def position(source)
      project = find_project!

      if source.index('/')
        # Full sprite/source pair given.
        sprite, source = source.split('/', 2)

        if project.sprite(sprite)
          sprites = [project.sprite(sprite)]
        else
          say "No such sprite: #{sprite}", :red
          exit 1
        end
      else
        # Only a source name was given.
        sprites = project.sprites
      end

      # Remove sprites which don't have a matching source.
      sprites.reject! { |sprite| not sprite.source(source) }
      say("No such source: #{source}") && exit(1) if sprites.empty?

      say ""

      sprites.each do |sprite|
        say "#{sprite.name}/#{source}: #{sprite.position_of(source)}px", :green
        say "    #{Flexo::CSSGenerator.background_statement(sprite, source)}"
        say "  - or -"
        say "    #{Flexo::CSSGenerator.position_statement(sprite, source)}"
        say ""
      end
    end

    # --- version ------------------------------------------------------------

    desc 'version', "Shows the version of Flexo you're using"
    map '--version' => :version

    def version
      say "Flexo #{Flexo::VERSION}"
    end

    private # ----------------------------------------------------------------

    # Returns the Project for the current directory. Exits with a message if
    # no project could be found.
    #
    # @return [Flexo::Project]
    #
    def find_project!
      Flexo::DSL.load Flexo::Project.find_config(Dir.pwd)
    rescue Flexo::MissingProject
      say <<-ERROR.compress_lines, :red
        Couldn't find a Flexo project in the current directory, or any of the
        parent directories. Run "flexo init" if you want to create a new
        project here.
      ERROR
      exit 1
    end

    def self.source_root
      File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
    end

    # Temporary -- until the next Thor release.
    def self.banner(task, namespace = nil, subcommand = false)
      super.gsub(/^.*flexo/, 'flexo')
    end

  end # CLI
end # Flexo
