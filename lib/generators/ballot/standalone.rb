# frozen_string_literal: true

require 'optparse'

#:nocov:

##
module Ballot
  module Generators
    # The Ballot standalone generator.
    class Standalone
      # Create and run the standalone generator with the command-line arguments.
      def self.run(argv)
        new(argv).run
      end

      # The arguments provided to the Standalone generator.
      attr_reader :argv

      # Create the standalone generator.
      def initialize(argv)
        @argv = argv
      end

      # Run the standalone generator.
      def run
        op = OptionParser.new { |opts|
          opts.banner = 'Usage: ballot_generator [options]'

          opts.on('--orm ORM', %w(active_record sequel), 'Select the ORM') do |orm|
            @orm = orm.to_sym
          end
          opts.on(
            '--install', '-I',
            Ballot::Generators::InstallGenerator.desc
          ) do
            if generator && !generator.kind_of?(Ballot::Generators::InstallGenerator)
              warn 'Can only select one generator to run.'
              $stderr.puts opts
              return 1
            else
              self.generator = Ballot::Generators::InstallGenerator.new
            end
          end
          opts.on(
            '--summary NAME', '-S',
            Ballot::Generators::SummaryGenerator.desc
          ) do |name|
            if generator && !generator.kind_of?(Ballot::Generators::SummaryGenerator)
              warn 'Can only select one generator to run.'
              $stderr.puts opts
              return 1
            else
              self.generator = Ballot::Generators::SummaryGenerator.new(name)
            end
          end

          opts.on('-h', '--help', 'Prints this help') do
            $stdout.puts opts
            return 1
          end
        }
        op.parse!(argv)

        if generator
          generator.class.orm = @orm if @orm
          generator.create_migration_file
        else
          $stdout.puts op
        end

        0
      rescue => ex
        $stderr.puts ex.message
        return 1
      end

      private

      attr_accessor :generator
    end
  end
end

require_relative 'standalone/support'
require_relative 'install/install_generator'
require_relative 'summary/summary_generator'

#:nocov:
