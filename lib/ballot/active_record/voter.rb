# frozen_string_literal: true

##
module Ballot
  module ActiveRecord
    # The Ballot::ActiveRecord::Voter module is the ActiveRecord-specific
    # implementation to enable Ballot::Voter for ActiveRecord.
    # for full details.
    module Voter
      def self.included(model) # :nodoc:
        require 'ballot/active_record/vote'
        require 'ballot/words'
        require 'ballot/voter'

        model.class_eval do
          has_many :ballots_by,
            class_name: '::Ballot::ActiveRecord::Vote',
            as: :voter,
            dependent: :destroy

          include Ballot::Voter
          extend Ballot::Voter::ClassMethods
        end
      end

      def cast_ballot_for(votable = nil, kwargs = {}) #:nodoc:
        kwargs = __ballot_voter_kwargs(votable, kwargs)
        votable = Ballot::ActiveRecord.votable_for(kwargs)
        return false unless votable
        votable.ballot_by(kwargs.merge(voter: self))
      end
      alias ballot_for cast_ballot_for

      def remove_ballot_for(votable = nil, kwargs = {}) #:nodoc:
        kwargs = __ballot_voter_kwargs(votable, kwargs)
        votable = Ballot::ActiveRecord.votable_for(kwargs)
        return false unless votable
        votable.remove_ballot_by voter: self, scope: kwargs[:scope]
      end

      def cast_ballot_for?(votable = nil, kwargs = {}) #:nodoc:
        kwargs = __ballot_voter_kwargs(votable, kwargs)
        votable_id, votable_type =
          Ballot::ActiveRecord.votable_id_and_type_name_for(kwargs)
        return false unless votable_id

        cond = {
          votable_id: votable_id,
          votable_type: votable_type,
          scope: kwargs[:scope]
        }
        cond[:vote] = Ballot::Words.truthy?(kwargs[:vote]) if kwargs.key?(:vote)

        find_ballots_by(cond).any?
      end
      alias ballot_for? cast_ballot_for?

      def ballot_as_cast_for(votable = nil, kwargs = {}) # :nodoc:
        kwargs = __ballot_voter_kwargs(votable, kwargs)
        votable = Ballot::ActiveRecord.votable_for(kwargs)
        return nil unless votable

        cond = {
          votable_id: votable.id,
          votable_type: Ballot::ActiveRecord.type_name(votable),
          scope: kwargs[:scope]
        }
        cond[:vote] = Ballot::Words.truthy?(kwargs[:vote]) if kwargs.key?(:vote)

        vote = find_ballots_by(cond).last
        vote && vote.vote
      end

      def ballots_for_class(klass, kwargs = {}) #:nodoc:
        cond = {
          votable_type: Ballot::ActiveRecord.type_name(klass),
          scope: kwargs[:scope]
        }
        cond[:vote] = Ballot::Words.truthy?(kwargs[:vote]) if kwargs.key?(:vote)

        find_ballots_by(cond)
      end

      private

      def find_ballots_by(*cond, &block)
        if cond.empty? && block.nil?
          ballots_by
        else
          ballots_by.where(*cond, &block)
        end
      end

      def __eager_ballot_votables(ds)
        ds.includes(:votable).map(&:votable)
      end
    end
  end
end
