# frozen_string_literal: true

module VotableExamples
  def it_is_a_votable_model(klass = nil, focus: false, &block)
    msg = 'a votable model'
    klass && msg = "#{klass} is #{msg}"

    describe msg do
      instance_exec(&block) if block

      describe '#vote_by' do
        self.focus if focus
        it 'is false when no voter is provided' do
          assert_false votable.vote_by
        end

        self.focus if focus
        it 'is false when the voter is not a model' do
          assert_false votable.vote_by voter: Class.new
        end

        self.focus if focus
        it 'is false when the voter is not a voter' do
          assert_false votable.vote_by voter: not_voter
        end

        self.focus if focus
        it 'creates a vote' do
          assert_true votable.vote_by voter: voter
          assert_true votable.votes_for.any?
          assert_equal 1, votable.votes_for_dataset.count
        end

        self.focus if focus
        it 'creates only one vote per person' do
          assert_true votable.vote_by voter: voter, vote: 'yes'
          assert_true votable.vote_by voter: voter, vote: 'no'
          assert_equal 1, votable.votes_for_dataset.count
        end

        self.focus if focus
        it 'creates only one vote per person, unless duplicates are allowed' do
          assert_true votable.vote_by voter: voter, vote: 'yes'
          assert_true votable.vote_by voter: voter, vote: 'no', duplicate: true
          assert_equal 2, votable.votes_for_dataset.count
        end

        self.focus if focus
        it 'creates a scoped vote' do
          assert_true votable.vote_by voter: voter, vote_scope: 'rank'
          assert_true votable.votes_for_dataset.where { vote_scope =~ 'rank' }.any?
        end

        self.focus if focus
        it 'creates only one scoped vote per person' do
          assert_true votable.vote_by voter: voter, vote_scope: 'rank'
          assert_true votable.vote_by voter: voter, vote_scope: 'rank', vote: 'no'
          assert_equal 1, votable.votes_for_dataset.where { vote_scope =~ 'rank' }.count
        end

        self.focus if focus
        it 'creates only one scoped vote per person, unless duplicates are allowed' do
          assert_true votable.vote_by voter: voter, vote_scope: 'rank'
          assert_true votable.vote_by voter: voter, vote_scope: 'rank', vote: 'no',
            duplicate: true
          assert_equal 2, votable.votes_for_dataset.where { vote_scope =~ 'rank' }.count
        end

        self.focus if focus
        it 'creates multiple votes with different scopes' do
          assert_true votable.vote_by voter: voter, vote_scope: 'weekly_rank'
          assert_true votable.vote_by voter: voter, vote_scope: 'monthly_rank'
          assert_equal 2, votable.votes_for_dataset.count
        end

        self.focus if focus
        it 'records separate votes for separate voters' do
          assert_true votable.vote_by voter: voter
          assert_true votable.vote_by voter: voter2
          assert_equal 2, votable.votes_for_dataset.count
        end

        self.focus if focus
        it 'uses a default vote weight of 1' do
          votable.vote_up_by voter
          assert_equal 1, votable.votes_for.first.vote_weight
        end
      end

      describe '#vote_up_by' do
        self.focus if focus
        it 'creates an up vote for the user' do
          assert_true votable.vote_up_by voter
          assert_true votable.votes_for_dataset.where(
            voter_id: voter.id,
            voter_type: voter.class.name,
            vote_flag: true
          ).any?
        end
      end

      describe '#vote_down_by' do
        self.focus if focus
        it 'creates a down vote for the user' do
          assert_true votable.vote_down_by voter
          assert_true votable.votes_for_dataset.where(
            voter_id: voter.id,
            voter_type: voter.class.name,
            vote_flag: false
          ).any?
        end
      end

      describe '#up_votes_for' do
        self.focus if focus
        it 'includes only positive votes' do
          votable.vote_up_by voter
          votable.vote_down_by voter2
          assert_equal 1, votable.up_votes_for.count
          assert_true votable.up_votes_for.
            where(voter_id: voter.id, voter_type: voter.class.name).any?
        end
      end

      describe '#down_votes_for' do
        self.focus if focus
        it 'includes only positive votes' do
          votable.vote_up_by voter
          votable.vote_down_by voter2
          assert_equal 1, votable.down_votes_for.count
          assert_true votable.down_votes_for.
            where(voter_id: voter2.id, voter_type: voter2.class.name).any?
        end
      end

      describe '#vote_registered?' do
        self.focus if focus
        it 'counts the vote as registered for the first vote' do
          assert_true votable.vote_up_by voter
          assert_true votable.vote_registered?
        end

        self.focus if focus
        it 'does not count a second unchanged vote as registered' do
          assert_true votable.vote_up_by voter
          assert_false votable.vote_up_by voter
          assert_false votable.vote_registered?
        end

        self.focus if focus
        it 'counts changed votes as registered' do
          assert_true votable.vote_up_by voter
          assert_true votable.vote_down_by voter
          assert_true votable.vote_registered?
        end

        self.focus if focus
        it 'counts vote weight changes as registered' do
          assert_true votable.vote_up_by voter
          assert_true votable.vote_up_by voter, vote_weight: 2
          assert_true votable.vote_registered?
        end

        self.focus if focus
        it 'belongs only to a particular instance' do
          votable.vote_down_by voter
          votable2.vote_up_by voter
          votable2.vote_up_by voter

          assert_true votable.vote_registered?
          assert_false votable2.vote_registered?
        end
      end

      describe '#voted_by?' do
        self.focus if focus
        it 'is true if the user voted' do
          assert_true votable.vote_up_by voter
          assert_true votable.voted_by?(voter)
        end

        self.focus if focus
        it 'is false if the user did not vote' do
          assert_false votable.voted_by?(voter)
        end
      end

      describe '#unvote_by' do
        self.focus if focus
        it 'removes an up vote' do
          assert_true votable.vote_up_by voter
          assert_true votable.unvote_by voter: voter
          assert_true votable.votes_for_dataset.none?
        end

        self.focus if focus
        it 'removes a down vote' do
          assert_true votable.vote_down_by voter
          assert_true votable.unvote_by voter: voter
          assert_true votable.votes_for_dataset.none?
        end

        self.focus if focus
        it 'sets vote_registered? to false' do
          assert_true votable.vote_up_by voter
          assert_true votable.unvote_by voter: voter
          assert_false votable.vote_registered?
        end

        self.focus if focus
        it 'removes only a single vote' do
          assert_true votable.vote_up_by voter
          assert_true votable.vote_up_by voter2
          assert_true votable.unvote_by voter: voter
          assert_true votable.votes_for_dataset.any?
          assert_true votable.votes_for_dataset.where(
            voter_id: voter.id,
            voter_type: voter.class.name
          ).none?
          assert_true votable.votes_for_dataset.where(
            voter_id: voter2.id,
            voter_type: voter2.class.name
          ).any?
        end
      end

      describe '#unvote_by' do
        self.focus if focus
        it 'removes an up vote' do
          assert_true votable.vote_up_by voter
          assert_true votable.unvote_by voter
          assert_true votable.votes_for_dataset.none?
        end

        self.focus if focus
        it 'removes a down vote' do
          assert_true votable.vote_down_by voter
          assert_true votable.unvote_by voter
          assert_true votable.votes_for_dataset.none?
        end

        self.focus if focus
        it 'sets vote_registered? to false' do
          assert_true votable.vote_up_by voter
          assert_true votable.unvote_by voter
          assert_false votable.vote_registered?
        end

        self.focus if focus
        it 'removes only a single vote' do
          assert_true votable.vote_up_by voter
          assert_true votable.vote_up_by voter2
          assert_true votable.unvote_by voter
          assert_true votable.votes_for_dataset.any?
          assert_true votable.votes_for_dataset.where(
            voter_id: voter.id,
            voter_type: voter.class.name
          ).none?
          assert_true votable.votes_for_dataset.where(
            voter_id: voter2.id,
            voter_type: voter2.class.name
          ).any?
        end
      end
    end
  end

  Minitest::Test.extend self
end
