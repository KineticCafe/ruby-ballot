# frozen_string_literal: true

module Sequel
  module Plugins
    module Voter
      def self.apply(model, _options = {})
        # Create a polymorphic one-to-many relationship for voters. Based
        # heavily on the one_to_many implementation from sequel_polymorphic,
        # but customized to sequel-voting's needs.
        model.one_to_many :votes_by,
          key: :voter_id,
          reciprocal: :voter,
          reciprocal_type: :one_to_many,
          conditions: { voter_type: Sequel::Voting.type_name(model) },
          adder: ->(many_of_instance) {
            many_of_instance.update(
              voter_id: pk,
              voter_type: Sequel::Voting.type_name(model)
            )
          },
          remover: ->(many_of_instance) {
            many_of_instance.update(voter_id: nil, voter_type: nil)
          },
          clearer: -> { votes_by.update(voter_id: nil, voter_type: nil) },
          class: 'Sequel::Voting::Vote'
      end

      module InstanceMethods
        def vote_for(votable = nil, args = {})
          args = __voter_args(votable, args)
          votable = Sequel::Voting.votable_for(args)
          return false unless votable
          votable.vote_by(args.merge(voter: self))
        end

        def vote_up_for(votable = nil, args = {})
          vote_for(votable, args.merge(vote: true))
        end

        def vote_down_for(votable = nil, args = {})
          vote_for(votable, args.merge(vote: false))
        end

        def unvote_for(votable = nil, args = {})
          args = __voter_args(votable, args)
          votable = Sequel::Voting.votable_for(args)
          return false unless votable
          votable.unvote_by voter: self, vote_scope: args[:vote_scope]
        end

        def voted_for?(votable = nil, args = {})
          args = __voter_args(votable, args)
          votable_id, votable_type = Sequel::Voting.votable_id_and_type_name_for(args)
          return false unless votable_id

          cond = {
            votable_id: votable_id,
            votable_type: votable_type,
            vote_scope: args[:vote_scope]
          }
          cond[:vote_flag] = args[:vote_flag] if args.key?(:vote_flag)

          find_votes_by(cond).any?
        end

        def voted_up_on?(votable = nil, args = {})
          voted_for?(votable, args.merge(vote_flag: true))
        end

        def voted_down_on?(votable = nil, args = {})
          voted_for?(votable, args.merge(vote_flag: false))
        end

        def voted_as_when_voted_on(votable = nil, args = {})
          args = __voter_args(votable, args)
          votable = Sequel::Voting.votable_for(args)
          return nil unless votable

          cond = {
            votable_id: votable.id,
            votable_type: Sequel::Voting.type_name(votable),
            vote_scope: args[:vote_scope]
          }
          cond[:vote_flag] = args[:vote_flag] if args.key?(:vote_flag)

          vote = find_votes_by(cond).last
          vote && vote.vote_flag
        end

        def up_votes_by(args = {})
          find_votes_by(vote_flag: true, vote_scope: args[:vote_scope])
        end

        def down_votes_by(args = {})
          find_votes_by(vote_flag: false, vote_scope: args[:vote_scope])
        end

        def votes_for_class(klass, args = {})
          klass = klass.kind_of?(String) ? klass : klass.name
          find_votes_by(args.merge(votable_type: klass))
        end

        def up_votes_for_class(klass, args = {})
          votes_for_class(klass, vote_flag: true, vote_scope: args[:vote_scope])
        end

        def down_votes_for_class(klass, args = {})
          votes_for_class(klass, vote_flag: false, vote_scope: args[:vote_scope])
        end

        def votables(*conds, &block)
          find_votes_by(*conds, &block).map(&:votable)
        end

        def up_votables(*conds, &block)
          find_votes_by(*conds, &block).where { vote_flag =~ true }.map(&:votable)
        end

        def down_votables(*conds, &block)
          find_votes_by(*conds, &block).where { vote_flag =~ false }.map(&:votable)
        end

        private

        def find_votes_by(*cond, &block)
          votes_by_dataset.where(*cond, &block)
        end

        def __voter_args(votable, args = {})
          if votable.kind_of?(Hash)
            args.merge(votable)
          elsif votable.nil?
            args
          else
            args.merge(votable: votable)
          end
        end
      end

      module ClassMethods
        # When plugin :voter is applied, a Sequel::Model is considered a voter.
        def voter?
          true
        end
      end
    end
  end
end
