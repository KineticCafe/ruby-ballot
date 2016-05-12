# frozen_string_literal: true

require 'sequel'

DB = if RUBY_ENGINE == 'jruby'
       Sequel.connect('jdbc:sqlite::memory:')
     else
       Sequel.sqlite
     end

class SQLLogger
  class << self
    def sqls
      Thread.current['sqls'] ||= []
    end

    def method_missing(_, msg)
      sqls << msg
    end

    def clear
      sqls.clear
    end
  end
end

DB.loggers << SQLLogger

DB.create_table? :ballot_votes do
  primary_key :id
  Integer :votable_id
  String :votable_type

  Integer :voter_id
  String :voter_type

  Boolean :vote
  String :scope
  Integer :weight

  DateTime :created_at, null: false, default: Sequel::CURRENT_TIMESTAMP
  DateTime :updated_at, null: false, default: Sequel::CURRENT_TIMESTAMP
end

%i(voters not_voters votables not_votables votable_voters).each do |table|
  DB.create_table? table do
    primary_key :id
    String :name
  end
end

%i(sti_votables sti_not_votables).each do |table|
  DB.create_table? table do
    primary_key :id
    String :name
    String :type
  end
end

DB.create_table? :votable_caches do
  primary_key :id

  String :name

  if Sequel.respond_to?(:pg_json)
    if respond_to?(:jsonb)
      jsonb :cached_ballot_summary
    else
      json :cached_ballot_summary
    end
  else
    String :cached_ballot_summary
  end
end

require 'ballot/sequel'

class SequelVoter < Sequel::Model(:voters)
  plugin :ballot_voter
end

class SequelNotVoter < Sequel::Model(:not_voters)
end

class SequelVotable < Sequel::Model(:votables)
  plugin :ballot_votable
end

class SequelNotVotable < Sequel::Model(:not_votables)
end

class SequelVotableVoter < Sequel::Model(:votable_voters)
  plugin :ballot_voter
  plugin :ballot_votable
end

class SequelStiVotable < Sequel::Model(:sti_votables)
  plugin :single_table_inheritance, :type
  plugin :ballot_votable
end

class SequelChildOfStiVotable < SequelStiVotable
end

class SequelStiNotVotable < Sequel::Model(:sti_not_votables)
  plugin :single_table_inheritance, :type
end

class SequelVotableChildOfStiNotVotable < SequelStiNotVotable
  plugin :ballot_votable
end

class SequelVotableCache < Sequel::Model(:votable_caches)
  plugin :ballot_votable
end

class SequelABoringClass
end

class Minitest::SequelSpec < Minitest::HooksSpec
  parallelize_me! unless RUBY_ENGINE == 'jruby'

  register_spec_type(/Sequel/, self)

  def around
    Sequel::Model.db.transaction(rollback: :always, auto_savepoint: true) { super }
  end

  def capture_sql
    SQLLogger.clear
    yield
    SQLLogger.sqls.dup
  ensure
    SQLLogger.clear
  end

  def votable_dataset(votable)
    votable.ballots_for_dataset
  end

  def voter_dataset(voter)
    voter.ballots_by_dataset
  end

  def ballot_type_name(item)
    Ballot::Sequel.type_name(item)
  end

  let(:voter) { SequelVoter.create(name: 'I can vote!') }
  let(:voter2) { SequelVoter.create(name: 'I, too, can vote!') }
  let(:not_voter) { SequelNotVoter.create(name: 'I cannot vote!') }

  let(:votable) { SequelVotable.create(name: 'a votable model') }
  let(:votable2) { SequelVotable.create(name: 'a second votable model') }
  let(:votable_cache) { SequelVotableCache.create(name: 'a votable model with caching') }
  let(:sti_votable) { SequelStiVotable.create(name: 'a votable STI model') }
  let(:child_of_sti_votable) {
    SequelChildOfStiVotable.create(name: 'a votable STI child model')
  }
  let(:votable_child_of_sti_not_votable) {
    SequelVotableChildOfStiNotVotable.create(name: 'a votable STI child of a non-votable')
  }
  let(:not_votable) { SequelNotVotable.create(name: 'a non-votable model') }
end
