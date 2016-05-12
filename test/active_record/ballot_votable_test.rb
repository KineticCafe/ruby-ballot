# frozen_string_literal: true

require 'minitest_config'

describe Ballot::ActiveRecord::Votable do
  describe_votable_models [
    ARVotable, ARVotableVoter, ARStiVotable, ARChildOfStiVotable,
    ARVotableChildOfStiNotVotable, ARVotableCache
  ]
  describe_non_votable_models [
    ARVoter, ARNotVoter, ARNotVotable, ARStiNotVotable
  ]
  describe_ballot_votable
  describe_ballot_votable_sti_support
  describe_cached_ballot_summary ARVotableCache
end
