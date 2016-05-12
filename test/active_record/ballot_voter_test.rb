# frozen_string_literal: true

require 'minitest_config'

describe Ballot::ActiveRecord::Voter do
  describe_non_voter_models [
    ARChildOfStiVotable, ARNotVotable, ARNotVoter, ARStiNotVotable,
    ARStiVotable, ARVotable, ARVotableCache, ARVotableChildOfStiNotVotable
  ]
  describe_voter_models [ ARVoter, ARVotableVoter ]
  describe_ballot_voter
  describe_ballot_voter_sti_votable_support
end
