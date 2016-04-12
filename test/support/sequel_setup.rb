# frozen_string_literal: true
require 'sqlite3'
require 'sequel'

DB = Sequel.sqlite

DB.create_table? :votes do
  primary_key :id
  Integer :votable_id
  String :votable_type

  Integer :voter_id
  String :voter_type

  Boolean :vote_flag
  String :vote_scope
  Integer :vote_weight

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
      jsonb :cached_vote_summary
    else
      json :cached_vote_summary
    end
  else
    String :cached_vote_summary
  end
end

require 'sequel/voting'

class Voter < Sequel::Model
  plugin :voter
end

class NotVoter < Sequel::Model
end

class Votable < Sequel::Model
  plugin :votable
end

class NotVotable < Sequel::Model
end

class VotableVoter < Sequel::Model
  plugin :voter
  plugin :votable
end

class StiVotable < Sequel::Model
  plugin :single_table_inheritance, :type
  plugin :votable
end

class ChildOfStiVotable < StiVotable
end

class StiNotVotable < Sequel::Model
  plugin :single_table_inheritance, :type
end

class VotableChildOfStiNotVotable < StiNotVotable
  plugin :votable
end

class VotableCache < Sequel::Model
  plugin :votable
end

class ABoringClass
end
