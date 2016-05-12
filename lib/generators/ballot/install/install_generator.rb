# frozen_string_literal: true

require 'generators/ballot'

##
module Ballot
  module Generators
    # The Rails generator to install the ballot_votes table.
    class InstallGenerator < ::Rails::Generators::Base
      include ::Rails::Generators::Migration if defined?(::Rails::Generators::Migration)
      extend Ballot::Generators

      desc <<-DESC
Description:
    Create the ballot_votes migration.
      DESC

      def create_migration_file #:nodoc:
        if self.class.orm_has_migration?
          migration_template 'migration.rb', 'db/migrate/install_ballot_vote_migration.rb'
        else
          warn "Unsupported ORM #{self.class.orm}"
        end
      end
    end
  end
end
