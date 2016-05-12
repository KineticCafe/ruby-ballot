# frozen_string_literal: true

module Sequel # :nodoc:
  module Plugins # :nodoc:
    # The votable plugin marks the model as containing objects that can be
    # voted on. It creates a polymorphic one-to-many relationship from the
    # Votable model to Ballot::Sequel::Vote.
    #
    # This may be used with single_table_inheritance, but should be loaded
    # *after* single_table_inheritance has been called. It has not been tested
    # with class_table_inheritance.
    #
    # This plug-in causes Ballot::Votable to be included into the affected
    # model, and Ballot::Votable::ClassMethods to be extended onto the affected
    # model.
    module BallotVotable
      def self.apply(model) # :nodoc:
        require 'ballot/sequel/vote'
        require 'ballot/words'
        require 'ballot/votable'

        model.instance_eval do
          if columns.include?(:cached_ballot_summary)
            plugin :serialization, :json, :cached_ballot_summary
          end

          # Create a polymorphic one-to-many relationship for votables. Based
          # heavily on the one_to_many implementation from sequel_polymorphic,
          # but customized to sequel-voting's needs.
          one_to_many :ballots_for,
            key: :votable_id,
            reciprocal: :votable,
            reciprocal_type: :one_to_many,
            conditions: { votable_type: Ballot::Sequel.type_name(model) },
            adder: ->(many_of_instance) {
              many_of_instance.update(
                votable_id: pk,
                votable_type: Ballot::Sequel.type_name(model)
              )
            },
            remover: ->(many_of_instance) { many_of_instance.delete },
            clearer: -> { ballots_for_dataset.delete },
            class: '::Ballot::Sequel::Vote'

          include Ballot::Votable
          extend Ballot::Votable::ClassMethods
        end
      end

      module InstanceMethods #:nodoc:
        def ballot_by(voter = nil, kwargs = {}) #:nodoc:
          kwargs = { vote: true, scope: nil }.
            merge(__ballot_votable_kwargs(voter, kwargs))
          self.ballot_registered = false

          voter_id, voter_type = Ballot::Sequel.voter_id_and_type_name_for(kwargs)
          return false unless voter_id

          votes_ = find_ballots_for(
            scope: kwargs[:scope],
            voter_id: voter_id,
            voter_type: voter_type
          )

          vote = if votes_.none? || kwargs[:duplicate]
                   Ballot::Sequel::Vote.new(
                     votable_id: id,
                     votable_type: Ballot::Sequel.type_name(model),
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

          model.db.transaction do
            if vote.save
              self.ballot_registered = true
              update_cached_votes kwargs[:scope]
              true
            end
          end
        end

        def remove_ballot_by(voter = nil, kwargs = {}) # :nodoc:
          kwargs = __ballot_votable_kwargs(voter, kwargs)
          voter_id, voter_type = Ballot::Sequel.voter_id_and_type_name_for(kwargs)
          return false unless voter_id

          votes_ = find_ballots_for(
            scope: kwargs[:scope],
            voter_id: voter_id,
            voter_type: voter_type
          )

          return true if votes_.none?

          model.db.transaction do
            votes_.each(&:destroy)
            update_cached_votes kwargs[:scope]
            self.ballot_registered = ballots_for_dataset.any?
            true
          end
        end

        def ballot_by?(voter = nil, kwargs = {}) #:nodoc:
          kwargs = __ballot_votable_kwargs(voter, kwargs)
          voter_id, voter_type = Ballot::Sequel.voter_id_and_type_name_for(kwargs)
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
            voter_type: Ballot::Sequel.type_name(klass),
            scope: kwargs[:scope]
          }
          cond[:vote] = Ballot::Words.truthy?(kwargs[:vote]) if kwargs.key?(:vote)

          find_ballots_for(cond)
        end

        private

        def caching_ballot_summary?
          model.columns.include?(:cached_ballot_summary)
        end

        def find_ballots_for(*cond, &block)
          ballots_for_dataset.where(*cond, &block)
        end

        def update_cached_votes(scope = nil)
          return false unless caching_ballot_summary?

          lock!
          summary = cached_ballot_summary.merge(calculate_summary(scope))
          self.cached_ballot_summary = summary
          save_changes
        end

        def __eager_ballot_voters(ds)
          ballots = ds.naked.select(:voter_type, :voter_id).all
          partitioned = ballots.group_by { |e| e[:voter_type] }
          partitioned.each_value do |value|
            value.map! { |e| e[:voter_id] }
          end
          partitioned.each_key do |key|
            voters = self.class.send(:constantize, key).
              where(id: partitioned[key]).
              map { |v| [ v.id, v ] }

            partitioned[key] = Hash[voters]
          end

          ballots.map { |ballot|
            partitioned[ballot[:voter_type]][ballot[:voter_id]]
          }
        end
      end
    end
  end
end
