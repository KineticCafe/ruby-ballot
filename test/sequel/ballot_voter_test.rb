# frozen_string_literal: true

require 'minitest_config'

describe Sequel::Plugins::BallotVoter do
  describe_non_voter_models [
    SequelChildOfStiVotable, SequelNotVotable, SequelNotVoter,
    SequelStiNotVotable, SequelStiVotable, SequelVotable, SequelVotableCache,
    SequelVotableChildOfStiNotVotable
  ]
  describe_voter_models [ SequelVoter, SequelVotableVoter ]
  describe_ballot_voter
  describe_ballot_voter_sti_votable_support

  describe 'association methods' do
    it '#add_ballots_by adds a new instance' do
      vote = Ballot::Sequel::Vote.new(votable: votable)
      refute_predicate vote, :valid?
      voter.add_ballots_by(vote)
      assert_predicate vote, :valid?
    end

    it '#remove_ballots_by destroys the instance' do
      voter.ballot_for votable
      assert_true Ballot::Sequel::Vote.any?
      voter.remove_ballots_by(voter_dataset(voter).first)
      assert_true Ballot::Sequel::Vote.none?
    end

    it '#remove_all_ballots_by destroys all instances' do
      voter.ballot_for votable
      voter2.ballot_for votable
      assert_true Ballot::Sequel::Vote.any?
      voter.remove_all_ballots_by
      assert_false Ballot::Sequel::Vote.none?
      assert_true Ballot::Sequel::Vote.where(
        voter_id: voter.id,
        voter_type: ballot_type_name(voter)
      ).none?
    end
  end
end
