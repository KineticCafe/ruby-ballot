# frozen_string_literal: true

require 'minitest_config'

describe Sequel::Plugins::Votable do
  describe '.votable?' do
    it 'models are not votable' do
      [
        Voter, NotVoter, NotVotable, StiNotVotable
      ].each { |model|
        assert_false model.votable?
        assert_false model.new.votable?
      }
    end

    it 'plugin :votable makes models votable' do
      [
        Votable, VotableVoter, StiVotable, ChildOfStiVotable,
        VotableChildOfStiNotVotable, VotableCache
      ].each { |model|
        assert_true model.votable?
        assert_true model.new.votable?
      }
    end
  end

  it_is_a_votable_model

  describe 'with STI support' do
    describe '#vote_by' do
      it 'works with STI models' do
        sti_votable.vote_by voter: voter
        assert_true sti_votable.votes_for_dataset.any?
      end

      it 'works with Child STI models' do
        child_of_sti_votable.vote_by voter: voter
        assert_true child_of_sti_votable.votes_for_dataset.any?
      end

      it 'works with votable children of non-votable STI models' do
        votable_child_of_sti_not_votable.vote_by voter: voter
        assert_true votable_child_of_sti_not_votable.votes_for_dataset.any?
      end
    end
  end

  describe 'with cached_vote_summary' do
    it 'does not update cached votes summary if there is no summary column' do
      instance_stub Votable, :total_votes do
        votable.vote_up_by voter
      end

      assert_instance_called Votable, :total_votes, 0
    end

    it 'updates the cached total' do
      assert_equal 0, votable_cache.total_votes

      votable_cache.vote_up_by voter
      assert_equal 1, votable_cache.total_votes

      votable_cache.vote_down_by voter2
      assert_equal 2, votable_cache.total_votes

      votable_cache.unvote_by voter
      assert_equal 1, votable_cache.total_votes
    end

    it 'updates the cached up votes' do
      assert_equal 0, votable_cache.total_votes_up

      votable_cache.vote_up_by voter
      assert_equal 1, votable_cache.total_votes_up

      votable_cache.vote_down_by voter2
      assert_equal 1, votable_cache.total_votes_up
    end

    it 'downdates the cached down votes' do
      assert_equal 0, votable_cache.total_votes_down

      votable_cache.vote_up_by voter
      assert_equal 0, votable_cache.total_votes_down

      votable_cache.vote_down_by voter2
      assert_equal 1, votable_cache.total_votes_down
    end

    it 'updates the cached score' do
      assert_equal 0, votable_cache.vote_score

      votable_cache.vote_down_by voter
      assert_equal -1, votable_cache.vote_score

      votable_cache.vote_down_by voter2
      assert_equal -2, votable_cache.vote_score

      votable_cache.unvote_by voter
      assert_equal -1, votable_cache.vote_score
    end

    it 'updates the weighted total' do
      assert_equal 0, votable_cache.weighted_total

      votable_cache.vote_up_by voter
      assert_equal 1, votable_cache.weighted_total

      votable_cache.vote_down_by voter2, vote_weight: 2
      assert_equal 3, votable_cache.weighted_total

      votable_cache.unvote_by voter
      assert_equal 2, votable_cache.weighted_total
    end

    it 'updates the weighted score' do
      assert_equal 0, votable_cache.weighted_score

      votable_cache.vote_down_by voter
      assert_equal -1, votable_cache.weighted_score

      votable_cache.vote_down_by voter2, vote_weight: 2
      assert_equal -3, votable_cache.weighted_score

      votable_cache.unvote_by voter
      assert_equal -2, votable_cache.weighted_score
    end

    describe 'under a scope' do
      it 'does not update cached votes summary if there is no summary column' do
        instance_stub Votable, :total_votes do
          votable.vote_up_by voter, vote_scope: 'scoped'
        end

        assert_instance_called Votable, :total_votes, 0
      end

      it 'does not affect the unscoped count' do
        assert_equal 0, votable_cache.total_votes

        votable_cache.vote_up_by voter, vote_scope: 'scoped'
        assert_equal 0, votable_cache.total_votes
      end

      it 'updates the cached total' do
        assert_equal 0, votable_cache.total_votes('scoped')

        votable_cache.vote_up_by voter, vote_scope: 'scoped'
        assert_equal 1, votable_cache.total_votes('scoped')

        votable_cache.vote_down_by voter2, vote_scope: 'scoped'
        assert_equal 2, votable_cache.total_votes('scoped')

        votable_cache.unvote_by voter, vote_scope: 'scoped'
        assert_equal 1, votable_cache.total_votes('scoped')
      end

      it 'updates the cached up votes' do
        assert_equal 0, votable_cache.total_votes_up('scoped')

        votable_cache.vote_up_by voter, vote_scope: 'scoped'
        assert_equal 1, votable_cache.total_votes_up('scoped')

        votable_cache.vote_down_by voter2
        assert_equal 1, votable_cache.total_votes_up('scoped')
      end

      it 'downdates the cached down votes' do
        assert_equal 0, votable_cache.total_votes_down('scoped')

        votable_cache.vote_up_by voter, vote_scope: 'scoped'
        assert_equal 0, votable_cache.total_votes_down('scoped')

        votable_cache.vote_down_by voter2, vote_scope: 'scoped'
        assert_equal 1, votable_cache.total_votes_down('scoped')
      end

      it 'updates the cached score' do
        assert_equal 0, votable_cache.vote_score('scoped')

        votable_cache.vote_down_by voter, vote_scope: 'scoped'
        assert_equal -1, votable_cache.vote_score('scoped')

        votable_cache.vote_down_by voter2, vote_scope: 'scoped'
        assert_equal -2, votable_cache.vote_score('scoped')

        votable_cache.unvote_by voter, vote_scope: 'scoped'
        assert_equal -1, votable_cache.vote_score('scoped')
      end

      it 'updates the weighted total' do
        assert_equal 0, votable_cache.weighted_total('scoped')

        votable_cache.vote_up_by voter, vote_scope: 'scoped'
        assert_equal 1, votable_cache.weighted_total('scoped')

        votable_cache.vote_down_by voter2, vote_weight: 2, vote_scope: 'scoped'
        assert_equal 3, votable_cache.weighted_total('scoped')

        votable_cache.unvote_by voter, vote_scope: 'scoped'
        assert_equal 2, votable_cache.weighted_total('scoped')
      end

      it 'updates the weighted score' do
        assert_equal 0, votable_cache.weighted_score('scoped')

        votable_cache.vote_down_by voter, vote_scope: 'scoped'
        assert_equal -1, votable_cache.weighted_score('scoped')

        votable_cache.vote_down_by voter2, vote_weight: 2, vote_scope: 'scoped'
        assert_equal -3, votable_cache.weighted_score('scoped')

        votable_cache.unvote_by voter, vote_scope: 'scoped'
        assert_equal -2, votable_cache.weighted_score('scoped')
      end
    end
  end
end
