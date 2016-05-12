# frozen_string_literal: true

require 'minitest_config'

describe 'RailsGenerator' do
  describe 'for Active Record' do
    let(:orm_name) { 'activerecord' }
    let(:orm_version) { ActiveRecord::VERSION::STRING }
    let(:rails_version) { orm_version }

    test_ballot_install(
      generate: %r{create\s+db/migrate/\d+_install_ballot_vote_migration},
      migrate: %r{
        InstallBallotVoteMigration.*
        --\screate_table\(:ballot_votes(?:,\s{})?\).*
        --\sadd_index\(:ballot_votes,\s\[:voter_id .*
        --\sadd_index\(:ballot_votes,\s\[:votable_id
      }mx,
      contents: /InstallBallotVoteMigration < ActiveRecord::Migration/
    )

    test_ballot_summary_votable(
      generate: %r{create\s+db/migrate/\d+_ballot_cache_for_votable},
      migrate: /BallotCacheForVotable.*--\schange_table\(:votables(?:,\s{})?\)/mx,
      contents: /BallotCacheForVotable < ActiveRecord::Migration/
    )
  end
end
