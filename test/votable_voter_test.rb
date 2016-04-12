# frozen_string_literal: true

require 'minitest_config'

describe VotableVoter do
  it_is_a_voter_model do
    let(:voter) { VotableVoter.create(name: 'I can vote!') }
    let(:voter2) { VotableVoter.create(name: 'I, too, can vote!') }
    let(:votable) { voter2 }
    let(:votable2) { voter }
  end

  it_is_a_votable_model do
    let(:voter) { VotableVoter.create(name: 'I can vote!') }
    let(:voter2) { VotableVoter.create(name: 'I, too, can vote!') }
    let(:votable) { voter2 }
    let(:votable2) { voter }
  end
end
