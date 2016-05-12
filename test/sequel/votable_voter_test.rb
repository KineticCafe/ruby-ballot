# frozen_string_literal: true

require 'minitest_config'

describe SequelVotableVoter do
  describe_ballot_voter do
    let(:voter) { SequelVotableVoter.create(name: 'I can vote!') }
    let(:voter2) { SequelVotableVoter.create(name: 'I, too, can vote!') }
    let(:votable) { voter2 }
    let(:votable2) { voter }
  end

  describe_ballot_votable do
    let(:voter) { SequelVotableVoter.create(name: 'I can vote!') }
    let(:voter2) { SequelVotableVoter.create(name: 'I, too, can vote!') }
    let(:votable) { voter2 }
    let(:votable2) { voter }
  end
end
