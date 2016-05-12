# frozen_string_literal: true

require 'generators/ballot'

##
module Ballot
  module Generators
    # The Rails generator to install the cache_ballot_summary column on the
    # indicated table.
    class SummaryGenerator < ::Rails::Generators::NamedBase
      include ::Rails::Generators::Migration if defined?(::Rails::Generators::Migration)
      extend Ballot::Generators

      desc <<-DESC
Description:
    Create a migration to add cached ballot summaries to the named table.
      DESC

      def create_migration_file #:nodoc:
        if self.class.orm_has_migration?
          migration_template 'migration.rb',
            "db/migrate/ballot_cache_for_#{file_name}.rb"
        end
      end
    end
  end
end
