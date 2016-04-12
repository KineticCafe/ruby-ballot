# frozen_string_literal: true

module Sequel
  module Plugins
    module Votable
      def self.apply(model)
        if caching_vote_summary?
          model.plugin :serialization, :json, :cached_vote_summary
        end

        # Create a polymorphic one-to-many relationship for votables. Based
        # heavily on the one_to_many implementation from sequel_polymorphic,
        # but customized to sequel-voting's needs.
        model.one_to_many :votes_for,
          key: :votable_id,
          reciprocal: :votable,
          reciprocal_type: :one_to_many,
          conditions: { votable_type: Sequel::Voting.type_name(model) },
          adder: ->(many_of_instance) {
            many_of_instance.update(
              votable_id: pk,
              votable_type: Sequel::Voting.type_name(model)
            )
          },
          remover: ->(many_of_instance) {
            many_of_instance.update(votable_id: nil, votable_type: nil)
          },
          clearer: -> { votes_for.update(votable_id: nil, votable_type: nil) },
          class: 'Sequel::Voting::Vote'
      end

      module InstanceMethods
        def initialize(*)
          super
          if model.columns.include?(:cached_vote_summary)
            self.cached_vote_summary ||= Hash.new { |h, k| h[k] = {} }
          end
        end

        def vote_registered?
          @vote_registered
        end

        def vote_by(voter = nil, args = {})
          args = { vote: true, vote_scope: nil }.merge(__votable_args(voter, args))
          self.vote_registered = false

          voter_id, voter_type = Sequel::Voting.voter_id_and_type_name_for(args)
          return false unless voter_id

          votes_ = find_votes_for(
            vote_scope: args[:vote_scope],
            voter_id: voter_id,
            voter_type: voter_type,
          )

          vote = if votes_.none? || args[:duplicate]
                   Sequel::Voting::Vote.new(
                     votable_id: id,
                     votable_type: Sequel::Voting.type_name(model),
                     voter_id: voter_id,
                     voter_type: voter_type,
                     vote_scope: args[:vote_scope]
                   )
                 else
                   votes_.last
                 end

          flag = Sequel::Voting::Words.true?(args[:vote])
          weight = args[:vote_weight] && args[:vote_weight].to_i || 1

          return false if vote.vote_flag == flag && vote.vote_weight == weight

          vote.vote_flag = flag
          vote.vote_weight = weight

          model.db.transaction do
            if vote.save
              self.vote_registered = true
              update_cached_votes args[:vote_scope]
              true
            end
          end
        end

        def vote_up_by(voter = nil, args = {})
          vote_by(voter, args.merge(vote: true))
        end

        def vote_down_by(voter = nil, args = {})
          vote_by(voter, args.merge(vote: false))
        end

        def unvote_by(voter = nil, args = {})
          args = __votable_args(voter, args)
          voter_id, voter_type = Sequel::Voting.voter_id_and_type_name_for(args)
          return false unless voter_id

          votes_ = find_votes_for(
            vote_scope: args[:vote_scope],
            voter_id: voter_id,
            voter_type: voter_type,
          )

          return true if votes_.none?

          model.db.transaction do
            votes_.each(&:destroy)

            update_cached_votes args[:vote_scope]
            self.vote_registered = votes_for.any?
            true
          end
        end

        def up_votes_for(args = {})
          find_votes_for(vote_flag: true, vote_scope: args[:vote_scope])
        end

        def down_votes_for(args = {})
          find_votes_for(vote_flag: false, vote_scope: args[:vote_scope])
        end

        def voted_by?(voter = nil, args = {})
          args = __votable_args(voter, args)
          voter_id, voter_type = Sequel::Voting.voter_id_and_type_name_for(args)
          return false unless voter_id

          cond = {
            voter_id: voter_id,
            voter_type: voter_type,
            vote_scope: args[:vote_scope]
          }
          cond[:vote_flag] = args[:vote_flag] if args.key?(:vote_flag)

          find_votes_for(cond).any?
        end

        def voted_up_by?(voter = nil, args = {})
          voted_by?(voter, args.merge(vote_flag: true))
        end

        def voted_down_by?(voter = nil, args = {})
          voted_by?(voter, args.merge(vote_flag: false))
        end

        def voters(*conds, &block)
          find_votes_for(*conds, &block).map(&:voter)
        end

        def up_voters(*conds, &block)
          find_votes_for(*conds, &block).where { vote_flag =~ true }.map(&:voter)
        end

        def down_voters(*conds, &block)
          find_votes_for(*conds, &block).where { vote_flag =~ false }.map(&:voter)
        end

        # Caching

        def total_votes(scope = nil, skip_cache: false)
          if !skip_cache && caching_vote_summary?
            scoped_cache_summary(scope)['total'].to_i
          else
            find_votes_for(vote_scope: scope).count
          end
        end

        def total_votes_up(scope = nil, skip_cache: false)
          if !skip_cache && caching_vote_summary?
            scoped_cache_summary(scope)['up'].to_i
          else
            up_votes_for(vote_scope: scope).count
          end
        end

        def total_votes_down(scope = nil, skip_cache: false)
          if !skip_cache && caching_vote_summary?
            scoped_cache_summary(scope)['down'].to_i
          else
            down_votes_for(vote_scope: scope).count
          end
        end

        def vote_score(scope = nil, skip_cache: false)
          if !skip_cache && caching_vote_summary?
            scoped_cache_summary(scope)['score'].to_i
          else
            total_votes_up(scope, skip_cache: skip_cache) -
              total_votes_down(scope, skip_cache: skip_cache)
          end
        end

        def weighted_total(scope = nil, skip_cache: false)
          if !skip_cache && caching_vote_summary?
            scoped_cache_summary(scope)['weighted_total'].to_i
          else
            up_votes_for(vote_scope: scope).sum(:vote_weight).to_i +
              down_votes_for(vote_scope: scope).sum(:vote_weight).to_i
          end
        end

        def weighted_score(scope = nil, skip_cache: false)
          if !skip_cache && caching_vote_summary?
            scoped_cache_summary(scope)['weighted_score'].to_i
          else
            up_votes_for(vote_scope: scope).sum(:vote_weight).to_i -
              down_votes_for(vote_scope: scope).sum(:vote_weight).to_i
          end
        end

        private

        attr_writer :vote_registered

        def caching_vote_summary?
          model.columns.include?(:cached_vote_summary)
        end

        def find_votes_for(*cond, &block)
          votes_for_dataset.where(*cond, &block)
        end

        def update_cached_votes(scope = nil)
          return false unless caching_vote_summary?

          lock!
          summary = cached_vote_summary.merge(calculate_summary(scope))
          self.cached_vote_summary = summary
          save_changes
        end

        def calculate_summary(scope = nil)
          {}.tap do |summary|
            summary[scope] ||= {}
            summary[scope]['total'] = total_votes(scope, skip_cache: true)
            summary[scope]['up'] = total_votes_up(scope, skip_cache: true)
            summary[scope]['down'] = total_votes_down(scope, skip_cache: true)
            summary[scope]['score'] = vote_score(scope, skip_cache: true)
            summary[scope]['weighted_total'] = weighted_total(scope, skip_cache: true)
            summary[scope]['weighted_score'] = weighted_score(scope, skip_cache: true)
          end
        end

        def scoped_cache_summary(scope = nil)
          cached_vote_summary[scope] || {}
        end

        def __votable_args(voter, args = {})
          if voter.kind_of?(Hash)
            args.merge(voter)
          elsif voter.nil?
            args
          else
            args.merge(voter: voter)
          end
        end
      end

      module ClassMethods
        # When plugin :votable is applied, a Sequel::Model is considered a
        # votable object.
        def votable?
          true
        end
      end

      module DatasetMethods
=begin
        subset(:voted)
        subset(:up_voted) { vote_flag: true }
        subset(:down_voted) { vote_flag: false }
=end
      end
    end
  end
end
