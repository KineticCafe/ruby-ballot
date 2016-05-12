# frozen_string_literal: true

require 'minitest_config'

describe Ballot::Sequel::Vote do
  before do
    voter.cast_up_ballot_for votable
    voter.cast_up_ballot_for votable2
    voter.cast_up_ballot_for votable_cache
    voter2.cast_down_ballot_for votable
    voter2.cast_down_ballot_for votable2
    voter2.cast_down_ballot_for votable_cache
    expected_votes # Force the query now
  end

  let(:expected_votes) {
    [
      Ballot::Sequel::Vote[1],
      Ballot::Sequel::Vote[2],
      Ballot::Sequel::Vote[3],
      Ballot::Sequel::Vote[4],
      Ballot::Sequel::Vote[5],
      Ballot::Sequel::Vote[6]
    ]
  }

  describe 'dataset_module' do
    it 'provides an up subset' do
      assert_equal 3, Ballot::Sequel::Vote.dataset.up.count
      assert_equal 3, Ballot::Sequel::Vote.up.count
    end

    it 'provides a down subset' do
      assert_equal 3, Ballot::Sequel::Vote.dataset.down.count
      assert_equal 3, Ballot::Sequel::Vote.down.count
    end

    it 'provides a for_type filter' do
      assert_empty Ballot::Sequel::Vote.dataset.for_type('SequelNotVotable')
      assert_empty Ballot::Sequel::Vote.for_type(SequelNotVotable)
      refute_empty Ballot::Sequel::Vote.dataset.for_type('SequelVotable')
      refute_empty Ballot::Sequel::Vote.for_type(SequelVotable)
    end

    it 'provides a by_type filter' do
      assert_empty Ballot::Sequel::Vote.dataset.by_type('SequelNotVoter')
      assert_empty Ballot::Sequel::Vote.by_type(SequelNotVoter)
      refute_empty Ballot::Sequel::Vote.dataset.by_type('SequelVoter')
      refute_empty Ballot::Sequel::Vote.by_type(SequelVoter)
    end
  end

  describe 'votable association' do
    it 'defines #votable= correctly' do
      v = Ballot::Sequel::Vote.new
      v.votable = votable
      assert_equal votable.id, v.votable_id
      assert_equal Ballot::Sequel.type_name(votable), v.votable_type
    end

    it 'defines votable_dataset correctly' do
      assert_equal votable, voter.ballots_by.first.votable
    end

    it 'defines eager loading correctly' do
      sqls = capture_sql {
        actual = Ballot::Sequel::Vote.eager(:votable).all
        assert_equal expected_votes, actual
        assert_equal [ votable, votable2, votable_cache ], actual.shift(3).map(&:votable)
        assert_equal [ votable, votable2, votable_cache ], actual.shift(3).map(&:votable)
      }

      assert_match(/SELECT \* FROM `ballot_votes`/, sqls.shift)
      assert_match(/SELECT \* FROM `votables` WHERE \(`id` IN \(1, 2\)\)/, sqls.shift)
      assert_match(/SELECT \* FROM `votable_caches` WHERE \(`id` IN \(1\)\)/, sqls.shift)
      assert_empty sqls
    end
  end

  describe 'voter association' do
    it 'defines #voter= correctly' do
      v = Ballot::Sequel::Vote.new
      v.voter = voter
      assert_equal voter.id, v.voter_id
      assert_equal Ballot::Sequel.type_name(voter), v.voter_type
    end

    it 'defines voter_dataset correctly' do
      assert_equal voter, votable.ballots_for_dataset.first.voter
    end

    it 'defines eager loading correctly' do
      sqls = capture_sql {
        actual = Ballot::Sequel::Vote.eager(:voter).all
        assert_equal expected_votes, actual
        assert_equal [ voter ] * 3, actual.shift(3).map(&:voter)
        assert_equal [ voter2 ] * 3, actual.shift(3).map(&:voter)
      }

      assert_match(/SELECT \* FROM `ballot_votes`/, sqls.shift)
      assert_match(/SELECT \* FROM `voters` WHERE \(`id` IN \(1, 2\)\)/, sqls.shift)
      assert_empty sqls
    end
  end
end
