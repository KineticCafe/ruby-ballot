# frozen_string_literal: true

Sequel.migration do
  change do
    create_table :ballot_votes do
      primary_key :id

      Integer :votable_id
      String :votable_type

      Integer :voter_id
      String :voter_type

      Boolean :vote, null: false, default: true
      String :scope
      Integer :weight

      DateTime :created_at, null: false, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, null: false, default: Sequel::CURRENT_TIMESTAMP

      add_index %i(votable_type votable_id scope), name: :ballot_votes_votable_by_scope
      add_index %i(voter_type voter_id scope), name: :ballot_votes_voter_by_scope
    end
  end
end
