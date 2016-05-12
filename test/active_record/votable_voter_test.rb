# frozen_string_literal: true

require 'minitest_config'

describe ARVotableVoter do
  describe_ballot_voter do
    let(:voter) { ARVotableVoter.create(name: 'I can vote!') }
    let(:voter2) { ARVotableVoter.create(name: 'I, too, can vote!') }
    let(:votable) { voter2 }
    let(:votable2) { voter }
  end

  describe_ballot_votable do
    let(:voter) { ARVotableVoter.create(name: 'I can vote!') }
    let(:voter2) { ARVotableVoter.create(name: 'I, too, can vote!') }
    let(:votable) { voter2 }
    let(:votable2) { voter }
  end
end
