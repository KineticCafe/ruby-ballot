# frozen_string_literal: true

require 'minitest_config'

describe Sequel::Plugins::Voter do
  describe '.voter?' do
    it 'models are not voters' do
      [
        ChildOfStiVotable, NotVotable, NotVoter, StiNotVotable, StiVotable,
        Votable, VotableCache, VotableChildOfStiNotVotable
      ].each { |model|
        assert_false model.voter?
        assert_false model.new.voter?
      }
    end

    it 'plugin :voter makes models voters' do
      [ Voter, VotableVoter ].each { |model|
        assert_true model.voter?
        assert_true model.new.voter?
      }
    end
  end

  it_is_a_voter_model

  describe 'with STI' do
    describe '#vote' do
      it 'works with STI models' do
        voter.vote_for sti_votable
        assert_true sti_votable.votes_for_dataset.any?
      end

      it 'works with Child STI models' do
        voter.vote_for child_of_sti_votable
        assert_true child_of_sti_votable.votes_for_dataset.any?
      end

      it 'works with votable children of non-votable STI models' do
        voter.vote_for votable_child_of_sti_not_votable
        assert_true votable_child_of_sti_not_votable.votes_for_dataset.any?
      end
    end

    describe '#vote_up_for' do
      it 'works with STI models' do
        voter.vote_up_for sti_votable
        assert_true sti_votable.votes_for_dataset.any?
      end

      it 'works with Child STI models' do
        voter.vote_up_for child_of_sti_votable
        assert_true child_of_sti_votable.votes_for_dataset.any?
      end

      it 'works with votable children of non-votable STI models' do
        voter.vote_up_for votable_child_of_sti_not_votable
        assert_true votable_child_of_sti_not_votable.votes_for_dataset.any?
      end
    end

    describe '#vote_down_for' do
      it 'works with STI models' do
        voter.vote_down_for sti_votable
        assert_true sti_votable.votes_for_dataset.any?
      end

      it 'works with Child STI models' do
        voter.vote_down_for child_of_sti_votable
        assert_true child_of_sti_votable.votes_for_dataset.any?
      end

      it 'works with votable children of non-votable STI models' do
        voter.vote_down_for votable_child_of_sti_not_votable
        assert_true votable_child_of_sti_not_votable.votes_for_dataset.any?
      end
    end
  end
end
