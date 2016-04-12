# frozen_string_literal: true
# -*- ruby encoding: utf-8 -*-

gem 'minitest'
require 'minitest/autorun'
require 'minitest/pretty_diff'
require 'minitest/focus'
require 'minitest/moar'
require 'minitest/bisect'
require 'minitest-bonus-assertions'
require 'minitest/hooks/default'

require 'pathname'

Dir["#{__dir__}/support/**/*.rb"].sort.each { |f| require_relative f }

class Minitest::HooksSpec
  def around
    Sequel::Model.db.transaction(rollback: :always, auto_savepoint: true) { super }
  end

  let(:voter) { Voter.create(name: 'I can vote!') }
  let(:voter2) { Voter.create(name: 'I, too, can vote!') }
  let(:not_voter) { NotVoter.create(name: 'I cannot vote!') }

  let(:votable) { Votable.create(name: 'a votable model') }
  let(:votable2) { Votable.create(name: 'a second votable model') }
  let(:votable_cache) { VotableCache.create(name: 'a votable model with caching') }
  let(:sti_votable) { StiVotable.create(name: 'a votable STI model') }
  let(:child_of_sti_votable) {
    ChildOfStiVotable.create(name: 'a votable STI child model')
  }
  let(:votable_child_of_sti_not_votable) {
    VotableChildOfStiNotVotable.create(name: 'a votable STI child of a non-votable')
  }
  let(:not_votable) { NotVotable.create(name: 'a non-votable model') }
end
