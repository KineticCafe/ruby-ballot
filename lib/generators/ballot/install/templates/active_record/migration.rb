# frozen_string_literal: true

class InstallBallotVoteMigration < ActiveRecord::Migration
  def change
    create_table :ballot_votes do |t|
      t.references :votable, polymorphic: true
      t.references :voter, polymorphic: true

      t.boolean :vote, null: false, default: true
      t.string :scope
      t.integer :weight

      t.timestamps null: false
    end

    add_index :ballot_votes, %i(voter_id voter_type scope)
    add_index :ballot_votes, %i(votable_id votable_type scope)
  end
end
