# frozen_string_literal: true

require 'active_record'

if RUBY_ENGINE == 'jruby'
  require 'activerecord-jdbcsqlite3-adapter'
else
  require 'sqlite3'
end

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

ActiveRecord::Schema.verbose = false
ActiveRecord::Schema.define(version: 1) do
  create_table :ballot_votes do |t|
    t.references :votable, polymorphic: true
    t.references :voter, polymorphic: true

    t.boolean :vote
    t.string :scope
    t.integer :weight

    t.timestamps null: false, default: 'now()'
  end

  add_index :ballot_votes, %i(voter_id voter_type scope)
  add_index :ballot_votes, %i(votable_id votable_type scope)

  %i(voters not_voters votables not_votables votable_voters).each do |table|
    create_table table do |t|
      t.string :name
    end
  end

  %i(sti_votables sti_not_votables).each do |table|
    create_table table do |t|
      t.string :name
      t.string :type
    end
  end

  create_table :votable_caches do |t|
    t.string :name

    if t.respond_to?(:jsonb)
      t.jsonb :cached_ballot_summary
    else
      t.string :cached_ballot_summary
    end
  end
end

require 'ballot/active_record'
Ballot::ActiveRecord.inject!

class ARVoter < ActiveRecord::Base
  self.table_name = 'voters'
  acts_as_ballot :voter
end

class ARNotVoter < ActiveRecord::Base
  self.table_name = 'not_voters'
end

class ARVotable < ActiveRecord::Base
  self.table_name = 'votables'
  acts_as_ballot :votable
end

class ARNotVotable < ActiveRecord::Base
  self.table_name = 'not_votables'
end

class ARVotableVoter < ActiveRecord::Base
  self.table_name = 'votable_voters'
  acts_as_ballot :voter
  acts_as_ballot :votable
end

class ARStiVotable < ActiveRecord::Base
  self.table_name = 'sti_votables'
  acts_as_ballot :votable
end

class ARChildOfStiVotable < ARStiVotable
end

class ARStiNotVotable < ActiveRecord::Base
  self.table_name = 'sti_not_votables'
end

class ARVotableChildOfStiNotVotable < ARStiNotVotable
  acts_as_ballot :votable
end

class ARVotableCache < ActiveRecord::Base
  self.table_name = 'votable_caches'
  acts_as_ballot :votable
end

class ARABoringClass
end

class Minitest::ActiveRecordSpec < Minitest::HooksSpec
  register_spec_type(/ActiveRecord|\AAR/, self)

  AbortTransaction = Class.new(StandardError)

  def around
    ActiveRecord::Base.connection.transaction do
      super
      fail AbortTransaction
    end
  rescue AbortTransaction
    true # This transaction has been deliberately aborted.
  end

  def votable_dataset(votable)
    votable.ballots_for
  end

  def voter_dataset(voter)
    voter.ballots_by
  end

  def ballot_type_name(item)
    Ballot::ActiveRecord.type_name(item)
  end

  let(:voter) { ARVoter.create(name: 'I can vote!') }
  let(:voter2) { ARVoter.create(name: 'I, too, can vote!') }
  let(:not_voter) { ARNotVoter.create(name: 'I cannot vote!') }

  let(:votable) { ARVotable.create(name: 'a votable model') }
  let(:votable2) { ARVotable.create(name: 'a second votable model') }
  let(:votable_cache) { ARVotableCache.create(name: 'a votable model with caching') }
  let(:sti_votable) { ARStiVotable.create(name: 'a votable STI model') }
  let(:child_of_sti_votable) {
    ARChildOfStiVotable.create(name: 'a votable STI child model')
  }
  let(:votable_child_of_sti_not_votable) {
    ARVotableChildOfStiNotVotable.create(name: 'a votable STI child of a non-votable')
  }
  let(:not_votable) { ARNotVotable.create(name: 'a non-votable model') }
end
