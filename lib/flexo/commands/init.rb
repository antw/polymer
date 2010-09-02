module Flexo
  module Commands
    # Creates a new project.
    class Init
      extend Commands

      # Path to lib/templates
      TEMPLATES = Pathname.new(__FILE__).dirname.parent + 'templates'

      # === Class Methods ====================================================

      # Creates a new project in the current directory.
      #
      # @param [Array] argv
      #   The arguments given on the command line.
      #
      def self.run(*)
        new(Dir.pwd).run!

      rescue Flexo::ProjectExists => e
        if e.message.match(/`(.*)'$/)[1] == Dir.pwd
          say color("A Flexo project already exists in the " \
            "current directory", :red)
        else
          say color(e.message.compress_lines, :red)
        end

        exit(1)
      end

      # === Instance Methods =================================================

      # Creates a new Generate instance.
      #
      # @param [Pathname]
      #   The directory in which a new project is to be created.
      #
      def initialize(dir)
        @dir = Pathname.new(dir)
      end

      # Runs the command, creating the new project structure.
      #
      def run!
        begin
          found = Project.find(@dir)
        rescue MissingProject
          ask_questions!
          make_directories!
          create_config!
          copy_sources!
          say color("Your project was created", :green)
          say Flexo::Commands::BLANK
        else
          raise Flexo::ProjectExists, <<-ERROR.compress_lines
            A Flexo project exists in a parent directory at
            `#{found.paths.root}'
          ERROR
        end
      end

      private # ==============================================================

      # Step 1: Ask the user where they want files to be stored.
      #
      def ask_questions!
        normalise_path = lambda do |path|
          npath = Pathname.new(path).expand_path
          npath = npath.relative_path_from(@dir) unless path[0].chr == '/'
          npath
        end

        @sprites_path =
          ask("Where do you want generated sprites to be stored?") do |query|
            query.default     = File.join('public', 'images')
            query.answer_type = normalise_path
          end

        @sources_path =
          ask("Where are the source images stored?") do |query|
            query.default     = (@sprites_path + "sprites").to_s
            query.answer_type = normalise_path
          end
      end

      # Step 2: Make the sprites and sources directories.
      #
      def make_directories!
        @sprites_path.mkpath unless @sprites_path.directory?
        @sources_path.mkpath unless @sources_path.directory?
      end

      # Step 3: Write the configuration.
      #
      def create_config!
        template = File.read(TEMPLATES + 'flexo.yml')
        template.gsub!(/<sprites>/, @sprites_path.to_s)
        template.gsub!(/<sources>/, @sources_path.to_s)

        File.open(@dir + '.flexo', 'w') do |config|
          config.puts template
        end
      end

      # Step 4: Copy the sample source images.
      #
      def copy_sources!
        FileUtils.cp_r(TEMPLATES + 'sources/.', @sources_path)
      end

    end # Init
  end # Commands
end # Flexo
