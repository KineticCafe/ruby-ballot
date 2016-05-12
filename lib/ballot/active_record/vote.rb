# frozen_string_literal: true

##
module Ballot
  module ActiveRecord
    # The ActiveRecord implementation of Ballot::Vote.
    class Vote < ::ActiveRecord::Base
      self.table_name = 'ballot_votes'

      scope :up, -> { where(vote: true) }
      scope :down, -> { where(vote: false) }

      scope :for_type, ->(model_class) {
        where(votable_type: Ballot::ActiveRecord.type_name(model_class))
      }
      scope :by_type, ->(model_class) {
        where(voter_type: Ballot::ActiveRecord.type_name(model_class))
      }

      if defined?(::ProtectedAttributes)
        attr_accessible :votable_id, :votable_type, :votable,
          :voter_id, :voter_type, :voter,
          :vote, :scope, :weight
      end

      belongs_to :votable, polymorphic: true
      belongs_to :voter, polymorphic: true

      validates :votable_type, presence: { allow_blank: false }
      validates :votable_id, presence: { allow_blank: false }
      validates :voter_type, presence: { allow_blank: false }
      validates :voter_id, presence: { allow_blank: false }
    end
  end
end
