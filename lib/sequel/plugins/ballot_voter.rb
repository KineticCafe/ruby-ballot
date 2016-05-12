# frozen_string_literal: true

module Sequel #:nodoc:
  module Plugins #:nodoc:
    # The BallotVoter plugin marks the model as containing objects that can
    # vote. It creates a polymorphic one-to-many relationship from the
    # BallotVoter model to Ballot::Sequel::Vote.
    module BallotVoter
      def self.apply(model) #:nodoc:
        require 'ballot/sequel/vote'
        require 'ballot/words'
        require 'ballot/voter'

        model.instance_eval do
          # Create a polymorphic one-to-many relationship for voters. Based
          # heavily on the one_to_many implementation from sequel_polymorphic,
          # but customized to sequel-voting's needs.
          one_to_many :ballots_by,
            key: :voter_id,
            reciprocal: :voter,
            reciprocal_type: :one_to_many,
            conditions: { voter_type: Ballot::Sequel.type_name(model) },
            adder: ->(many_of_instance) {
              many_of_instance.update(
                voter_id: pk,
                voter_type: Ballot::Sequel.type_name(model)
              )
            },
            remover: ->(many_of_instance) { many_of_instance.delete },
            clearer: -> { ballots_by_dataset.delete },
            class: '::Ballot::Sequel::Vote'

          include Ballot::Voter
          extend Ballot::Voter::ClassMethods
        end
      end

      module InstanceMethods #:nodoc:
        def cast_ballot_for(votable = nil, kwargs = {}) #:nodoc:
          kwargs = __ballot_voter_kwargs(votable, kwargs)
          votable = Ballot::Sequel.votable_for(kwargs)
          return false unless votable
          votable.ballot_by(kwargs.merge(voter: self))
        end
        alias ballot_for cast_ballot_for

        def remove_ballot_for(votable = nil, kwargs = {}) #:nodoc:
          kwargs = __ballot_voter_kwargs(votable, kwargs)
          votable = Ballot::Sequel.votable_for(kwargs)
          return false unless votable
          votable.remove_ballot_by voter: self, scope: kwargs[:scope]
        end

        def cast_ballot_for?(votable = nil, kwargs = {}) #:nodoc:
          kwargs = __ballot_voter_kwargs(votable, kwargs)
          votable_id, votable_type = Ballot::Sequel.votable_id_and_type_name_for(kwargs)
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

        def ballot_as_cast_for(votable = nil, kwargs = {}) #:nodoc:
          kwargs = __ballot_voter_kwargs(votable, kwargs)
          votable = Ballot::Sequel.votable_for(kwargs)
          return nil unless votable

          cond = {
            votable_id: votable.id,
            votable_type: Ballot::Sequel.type_name(votable),
            scope: kwargs[:scope]
          }
          cond[:vote] = Ballot::Words.truthy?(kwargs[:vote]) if kwargs.key?(:vote)

          vote = find_ballots_by(cond).
            order(Sequel.desc(:updated_at), Sequel.desc(:created_at)).
            limit(1).first
          vote && vote.vote
        end

        def ballots_for_class(klass, kwargs = {}) #:nodoc:
          cond = {
            votable_type: Ballot::Sequel.type_name(klass),
            scope: kwargs[:scope]
          }
          cond[:vote] = Ballot::Words.truthy?(kwargs[:vote]) if kwargs.key?(:vote)

          find_ballots_by(cond)
        end

        private

        def find_ballots_by(*cond, &block)
          ballots_by_dataset.where(*cond, &block)
        end

        def __eager_ballot_votables(ds)
          ballots = ds.naked.select(:votable_type, :votable_id).all
          partitioned = ballots.group_by { |e| e[:votable_type] }
          partitioned.each_value do |value|
            value.map! { |e| e[:votable_id] }
          end
          partitioned.each_key do |key|
            votables = self.class.send(:constantize, key).
              where(id: partitioned[key]).
              map { |v| [ v.id, v ] }

            partitioned[key] = Hash[votables]
          end

          ballots.map { |ballot|
            partitioned[ballot[:votable_type]][ballot[:votable_id]]
          }
        end
      end
    end
  end
end
