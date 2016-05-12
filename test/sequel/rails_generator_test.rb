# frozen_string_literal: true

require 'minitest_config'

describe 'RailsGenerator' do
  describe 'for Sequel' do
    let(:orm_name) { 'sequel' }
    let(:orm_version) { Sequel::VERSION }
    let(:rails_version) { ActiveRecord::VERSION::STRING }

    test_ballot_install(
      generate: %r{create\s+db/migrate/\d+_install_ballot_vote_migration},
      contents: /Sequel.migration.*create_table :ballot_votes do/m
    )

    test_ballot_summary_votable(
      generate: %r{create\s+db/migrate/\d+_ballot_cache_for_votable},
      contents: %r{
        Sequel.migration.*
        alter_table\s+:'votables'.*
        add_column\s+:cached_ballot_summary,
      }mx
    )
  end
end
