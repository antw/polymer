module Flexo
  # Contains support for PNGOUT, OptiPNG, and PNGCrush.
  module Optimisation

    # Returns an array of optimisers supported on the current system.
    #
    # @return [Array<Flexo::Optimisation::Optimiser>]
    #
    def self.optimisers
      @optimisers ||=
        [PNGOut, OptiPNG, PNGCrush].select { |o| o.supported? }.map(&:new)
    end

    # Given a path to a file, runs all of the available optimisers until
    # either:
    #
    #   1. No further optimisations could be found.
    #   2. Each optimiser has been run three times.
    #
    # @param [Pathname] path
    #   Path to the file to be optimised.
    #
    # @return [Integer, false]
    #   Returns the number of bytes by which the filesize was reduced or false
    #   if there are no available optimisers.
    #
    def self.optimise_file(path)
      return false if optimisers.empty?

      reduction = 0
      skip = []

      3.times do |i|
        before_iteration = reduction

        optimisers.each do |optimiser|
          next if skip.include?(optimiser)

          if (opt_reduction = optimiser.run(path)) > 0
            reduction += opt_reduction
          else
            # This optimiser can't find any more savings, don't run
            # it again.
            skip << optimiser
          end
        end # optimisers.each

        # If the iteration found no savings, return immediately rather than
        # running them again.
        return reduction if before_iteration >= reduction
      end # 3.times

      reduction
    end

    # A base optimiser class.
    class Optimiser
      COMMAND = ''

      # Runs the optimiser on a file once. Running again may yield further
      # reductions in file size.
      #
      # @param [Pathname] path
      #   Path to the file to be optimised.
      #
      # @return [Integer]
      #   Returns the number of bytes by which the filesize was reduced.
      #
      # @see [Flexo::Optimisation.optimise_file]
      #
      def run(path)
        before_size = path.size
        `#{self.class::COMMAND.gsub(/\[PATH\]/, path.to_s)}`
        before_size - path.size
      end

      # Tests if the optimiser is supported on the current system.
      #
      # @return [Boolean]
      #
      def self.supported?
        unless defined?(@supported)
          stdout = `which #{self::COMMAND.split(' ', 2).first}`
          @supported = $?.exitstatus.zero? && stdout !~ /not found/
        end

        @supported
      end
    end # Optimiser

    # An optimiser which uses PNGOUT. pngout may also be called
    # "pngout-darwin" if installed using MacPorts.
    class PNGOutDefault < Optimiser
      COMMAND = 'pngout [PATH] [PATH] -s0 -k0 -y'
    end

    # MacPorts installs a pngout-darwin binary.
    class PNGOutDarwin < PNGOutDefault
      COMMAND = 'pngout-darwin [PATH] [PATH] -s0 -k0 -y'
    end

    # An optimiser which uses OptiPNG.
    class OptiPNG < Optimiser
      COMMAND = 'optipng [PATH]'
    end # OptiPNG

    # An optimiser which uses PNGCrush.
    class PNGCrush < Optimiser
      COMMAND = 'pngcrush -brute -e .png.tmp [PATH]'

      # PNGCrush doesn't overwrite existing files. Instead the -e (extension)
      # option is used to write to a temporary file, which is them moved over
      # the new file.
      def run(path)
        super
        FileUtils.rm(path)
        FileUtils.mv(path.to_s + '.tmp', path)
      end
    end # PNGCrush

    # Which PNGOUT should we use?
    if not PNGOutDefault.supported? and PNGOutDarwin.supported?
      PNGOut = PNGOutDarwin
    else
      PNGOut = PNGOutDefault
    end

  end # Optimisation
end # Flexo
