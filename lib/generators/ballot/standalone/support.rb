# frozen_string_literal: true

require 'erb'

#:nocov:
#:stopdoc:

# Everything in this file is wrong, except that it does the right thing to
# simplify the overall implementation of standalone generators.
module Rails
  module Generators
    # Implement just enough of Generators to be useful.
    class Base #:nodoc:
      def self.desc(value = nil)
        @desc = value.gsub(/^Description:\n\s+/, '').chomp if value
        @desc
      end

      def self.generator_name
        name.split(/::/).last.sub(/Generator/, '').downcase
      end

      attr_reader :argv
      attr_accessor :destination

      def migration_template(source, target)
        data = File.read(File.join(self.class.source_root, source))
        data = ERB.new(data, 0, '%<>>-').result(binding)

        path, file = File.split(target)

        file = "#{self.class.next_migration_number(nil)}_#{file}"

        File.write(File.join(destination || path, file), data)
      end
    end

    class NamedBase < Base #:nodoc:
      def initialize(name)
        @name = prepare_name(name)
      end

      def plural_table_name
        "#{@name}s"
      end

      def class_name
        @name.gsub(/^(.)|_(.)/) { (Regexp.last_match(1) || Regexp.last_match(2)).upcase }
      end

      def file_name
        @name
      end

      private

      def prepare_name(name)
        name.split(/::/).
          last.
          gsub(/([A-Z])/, '_\1').
          downcase.
          sub(/^_/, '').
          sub(/s$/, '')
      end
    end
  end
end

#:startdoc:
#:nocov:
