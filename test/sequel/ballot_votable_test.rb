# frozen_string_literal: true

require 'minitest_config'

describe Sequel::Plugins::BallotVotable do
  describe_votable_models [
    SequelVotable, SequelVotableVoter, SequelStiVotable,
    SequelChildOfStiVotable, SequelVotableChildOfStiNotVotable,
    SequelVotableCache
  ]
  describe_non_votable_models [
    SequelVoter, SequelNotVoter, SequelNotVotable, SequelStiNotVotable
  ]
  describe_ballot_votable
  describe_ballot_votable_sti_support
  describe_cached_ballot_summary SequelVotableCache

  describe 'association methods' do
    it '#add_ballots_for adds a new instance' do
      vote = Ballot::Sequel::Vote.new(voter: voter)
      refute_predicate vote, :valid?
      votable.add_ballots_for(vote)
      assert_predicate vote, :valid?
    end

    it '#remove_ballots_for destroys the instance' do
      votable.ballot_by voter
      assert_true Ballot::Sequel::Vote.any?
      votable.remove_ballots_for(votable_dataset(votable).first)
      assert_true Ballot::Sequel::Vote.none?
    end

    it '#remove_all_ballots_for destroys all instances' do
      votable.ballot_by voter
      votable2.ballot_by voter
      assert_true Ballot::Sequel::Vote.any?
      votable.remove_all_ballots_for
      assert_false Ballot::Sequel::Vote.none?
      assert_true Ballot::Sequel::Vote.where(
        votable_id: votable.id,
        votable_type: ballot_type_name(votable)
      ).none?
    end
  end
end
