# frozen_string_literal: true

##
module Ballot
  module ActiveRecord
    # The Ballot::ActiveRecord::Votable module is the ActiveRecord-specific
    # implementation to enable Ballot::Votable for ActiveRecord.
    module Votable
      def self.included(model) #:nodoc:
        require 'ballot/active_record/vote'
        require 'ballot/words'
        require 'ballot/votable'

        model.class_eval do
          # NOTE: This should only be done when Postgres JSON support is not
          # enabled.
          serialize :cached_ballot_summary, JSON

          has_many :ballots_for,
            class_name: '::Ballot::ActiveRecord::Vote',
            as: :votable,
            dependent: :destroy

          include Ballot::Votable
          extend Ballot::Votable::ClassMethods
        end
      end

      def ballot_by(voter = nil, kwargs = {}) #:nodoc:
        kwargs = { vote: true, scope: nil }.
          merge(__ballot_votable_kwargs(voter, kwargs))
        self.ballot_registered = false

        voter_id, voter_type = Ballot::ActiveRecord.voter_id_and_type_name_for(kwargs)
        return false unless voter_id

        votes_ = find_ballots_for(
          scope: kwargs[:scope],
          voter_id: voter_id,
          voter_type: voter_type
        )

        vote = if votes_.none? || kwargs[:duplicate]
                 Ballot::ActiveRecord::Vote.new(
                   votable: self,
                   voter_id: voter_id,
                   voter_type: voter_type,
                   scope: kwargs[:scope]
                 )
               else
                 votes_.last
               end

        flag = Ballot::Words.truthy?(kwargs[:vote])
        weight = kwargs[:weight] && kwargs[:weight].to_i || 1

        return false if vote.vote == flag && vote.weight == weight

        vote.vote = flag
        vote.weight = weight

        transaction do
          if vote.save
            self.ballot_registered = true
            update_cached_votes kwargs[:scope]
            true
          end
        end
      end

      def remove_ballot_by(voter = nil, kwargs = {}) #:nodoc:
        kwargs = __ballot_votable_kwargs(voter, kwargs)
        voter_id, voter_type = Ballot::ActiveRecord.voter_id_and_type_name_for(kwargs)
        return false unless voter_id

        votes_ = find_ballots_for(
          scope: kwargs[:scope],
          voter_id: voter_id,
          voter_type: voter_type
        )

        return true if votes_.none?

        transaction do
          votes_.each(&:destroy)
          update_cached_votes kwargs[:scope]
          self.ballot_registered = ballots_for.any?
          true
        end
      end

      def ballot_by?(voter = nil, kwargs = {}) #:nodoc:
        kwargs = __ballot_votable_kwargs(voter, kwargs)
        voter_id, voter_type = Ballot::ActiveRecord.voter_id_and_type_name_for(kwargs)
        return false unless voter_id

        cond = {
          voter_id: voter_id,
          voter_type: voter_type,
          scope: kwargs[:scope]
        }
        cond[:vote] = Ballot::Words.truthy?(kwargs[:vote]) if kwargs.key?(:vote)

        find_ballots_for(cond).any?
      end

      def ballots_by_class(klass, kwargs = {}) #:nodoc:
        cond = {
          voter_type: Ballot::ActiveRecord.type_name(klass),
          scope: kwargs[:scope]
        }
        cond[:vote] = Ballot::Words.truthy?(kwargs[:vote]) if kwargs.key?(:vote)

        find_ballots_for(cond)
      end

      private

      def caching_ballot_summary?
        attribute_names.include?('cached_ballot_summary')
      end

      def find_ballots_for(*cond, &block)
        if cond.empty? && block.nil?
          ballots_for
        else
          ballots_for.where(*cond, &block)
        end
      end

      def update_cached_votes(scope = nil)
        return false unless caching_ballot_summary?

        lock!
        summary = cached_ballot_summary.merge(calculate_summary(scope))
        self.cached_ballot_summary = summary
        save!
      end

      def __eager_ballot_voters(ds)
        ds.includes(:voter).map(&:voter)
      end
    end
  end
end
