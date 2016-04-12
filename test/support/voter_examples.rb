# frozen_string_literal: true

module VoterExamples
  def it_is_a_voter_model(klass = nil, focus: false, &block)
    msg = 'a voter model'
    klass && msg = "#{klass} is #{msg}"

    describe msg do
      instance_exec(&block) if block

      describe '#vote_for' do
        self.focus if focus
        it 'is false when no votable is provided' do
          assert_false voter.vote_for
        end

        self.focus if focus
        it 'is false when the votable is not a model' do
          assert_false voter.vote_for Class.new
        end

        self.focus if focus
        it 'is false when the votable is not a votable' do
          assert_false voter.vote_for not_votable
        end

        self.focus if focus
        it 'is true when a vote succeeds' do
          assert_true voter.vote_for votable
        end

        self.focus if focus
        it 'adds a vote' do
          assert_true voter.vote_for votable
          assert_true voter.votes_by.any?
          assert_equal 1, votable.votes_for_dataset.count
        end

        self.focus if focus
        it 'creates only one vote per item' do
          voter.vote_for votable: votable
          assert_true voter.vote_for votable_id: votable.id,
            votable_type: Sequel::Voting.type_name(votable), vote: 'no'
          assert_equal 1, votable.votes_for_dataset.count
        end

        self.focus if focus
        it 'creates only one vote per item, unless duplicates are allowed' do
          voter.vote_for votable: votable
          assert_true voter.vote_for votable: votable, duplicate: true
          assert_equal 2, votable.votes_for_dataset.count
        end

        self.focus if focus
        it 'creates a scoped vote' do
          voter.vote_for votable: votable, vote_scope: 'rank'
          assert_true votable.votes_for_dataset.where { vote_scope =~ 'rank' }.any?
        end

        self.focus if focus
        it 'creates only one scoped vote per person' do
          voter.vote_for votable: votable, vote_scope: 'rank'
          voter.vote_for votable: votable, vote_scope: 'rank', vote: 'no'
          assert_equal 1, votable.votes_for_dataset.where { vote_scope =~ 'rank' }.count
        end

        self.focus if focus
        it 'creates only one scoped vote per person, unless duplicates are allowed' do
          voter.vote_for votable: votable, vote_scope: 'rank'
          assert_true voter.vote_for votable: votable, vote_scope: 'rank', vote: 'no',
            duplicate: true
          assert_equal 2, votable.votes_for_dataset.where { vote_scope =~ 'rank' }.count
        end

        self.focus if focus
        it 'creates multiple votes with different scopes' do
          assert_true voter.vote_for votable: votable, vote_scope: 'weekly_rank'
          assert_true voter.vote_for votable: votable, vote_scope: 'monthly_rank'
          assert_equal 2, votable.votes_for_dataset.count
        end

        self.focus if focus
        it 'records separate votes for separate voters' do
          assert_true voter.vote_for votable: votable
          assert_true voter2.vote_for votable: votable
          assert_equal 2, votable.votes_for_dataset.count
        end

        self.focus if focus
        it 'uses a default vote weight of 1' do
          voter.vote_for votable
          assert_equal 1, votable.votes_for.first.vote_weight
        end
      end

      describe '#vote_up_for' do
        self.focus if focus
        it 'is false when the votable is not a model' do
          assert_false voter.vote_up_for Class.new
        end

        self.focus if focus
        it 'is false when the votable is not a votable' do
          assert_false voter.vote_up_for not_votable
        end

        self.focus if focus
        it 'is true when a vote succeeds' do
          assert_true voter.vote_up_for votable
        end

        self.focus if focus
        it 'adds a vote' do
          assert_true voter.vote_up_for votable
          assert_true voter.votes_by.any?
          assert_equal 1, votable.votes_for_dataset.count
        end

        self.focus if focus
        it 'creates only one vote per item' do
          voter.vote_up_for votable
          assert_false voter.vote_up_for votable, vote: 'no'
          assert_equal 1, votable.votes_for_dataset.count
        end

        self.focus if focus
        it 'creates only one vote per item, unless duplicates are allowed' do
          voter.vote_up_for votable
          assert_true voter.vote_up_for votable, duplicate: true
          assert_equal 2, votable.votes_for_dataset.count
        end

        self.focus if focus
        it 'creates a scoped vote' do
          voter.vote_up_for votable, vote_scope: 'rank'
          assert_true votable.votes_for_dataset.where { vote_scope =~ 'rank' }.any?
        end

        self.focus if focus
        it 'creates only one scoped vote per person' do
          voter.vote_up_for votable, vote_scope: 'rank'
          voter.vote_up_for votable, vote_scope: 'rank', vote: 'no'
          assert_equal 1, votable.votes_for_dataset.where { vote_scope =~ 'rank' }.count
        end

        self.focus if focus
        it 'creates only one scoped vote per person, unless duplicates are allowed' do
          voter.vote_up_for votable, vote_scope: 'rank'
          assert_true voter.vote_up_for votable, vote_scope: 'rank', vote: 'no',
            duplicate: true
          assert_equal 2, votable.votes_for_dataset.where { vote_scope =~ 'rank' }.count
        end

        self.focus if focus
        it 'creates multiple votes with different scopes' do
          assert_true voter.vote_up_for votable, vote_scope: 'weekly_rank'
          assert_true voter.vote_up_for votable, vote_scope: 'monthly_rank'
          assert_equal 2, votable.votes_for_dataset.count
        end

        self.focus if focus
        it 'records separate votes for separate voters' do
          assert_true voter.vote_up_for votable
          assert_true voter2.vote_up_for votable
          assert_equal 2, votable.votes_for_dataset.count
        end

        self.focus if focus
        it 'uses a default vote weight of 1' do
          voter.vote_up_for votable
          assert_equal 1, votable.votes_for.first.vote_weight
        end
      end

      describe '#vote_down_for' do
        self.focus if focus
        it 'is false when the votable is not a model' do
          assert_false voter.vote_down_for Class.new
        end

        self.focus if focus
        it 'is false when the votable is not a votable' do
          assert_false voter.vote_down_for not_votable
        end

        self.focus if focus
        it 'is true when a vote succeeds' do
          assert_true voter.vote_down_for votable
        end

        self.focus if focus
        it 'adds a vote' do
          assert_true voter.vote_down_for votable
          assert_true voter.votes_by.any?
          assert_equal 1, votable.votes_for_dataset.count
        end

        self.focus if focus
        it 'creates only one vote per item' do
          voter.vote_down_for votable
          assert_false voter.vote_down_for votable, vote: 'no'
          assert_equal 1, votable.votes_for_dataset.count
        end

        self.focus if focus
        it 'creates only one vote per item, unless duplicates are allowed' do
          voter.vote_down_for votable
          assert_true voter.vote_down_for votable, duplicate: true
          assert_equal 2, votable.votes_for_dataset.count
        end

        self.focus if focus
        it 'creates a scoped vote' do
          voter.vote_down_for votable, vote_scope: 'rank'
          assert_true votable.votes_for_dataset.where { vote_scope =~ 'rank' }.any?
        end

        self.focus if focus
        it 'creates only one scoped vote per person' do
          voter.vote_down_for votable, vote_scope: 'rank'
          voter.vote_down_for votable, vote_scope: 'rank', vote: 'no'
          assert_equal 1, votable.votes_for_dataset.where { vote_scope =~ 'rank' }.count
        end

        self.focus if focus
        it 'creates only one scoped vote per person, unless duplicates are allowed' do
          voter.vote_down_for votable, vote_scope: 'rank'
          assert_true voter.vote_down_for votable, vote_scope: 'rank', vote: 'no',
            duplicate: true
          assert_equal 2, votable.votes_for_dataset.where { vote_scope =~ 'rank' }.count
        end

        self.focus if focus
        it 'creates multiple votes with different scopes' do
          assert_true voter.vote_down_for votable, vote_scope: 'weekly_rank'
          assert_true voter.vote_down_for votable, vote_scope: 'monthly_rank'
          assert_equal 2, votable.votes_for_dataset.count
        end

        self.focus if focus
        it 'records separate votes for separate voters' do
          assert_true voter.vote_down_for votable
          assert_true voter2.vote_down_for votable
          assert_equal 2, votable.votes_for_dataset.count
        end

        self.focus if focus
        it 'uses a default vote weight of 1' do
          voter.vote_down_for votable
          assert_equal 1, votable.votes_for.first.vote_weight
        end
      end

      describe '#unvote_for' do
        self.focus if focus
        it 'removes an up vote' do
          voter.vote_up_for votable
          assert_true voter.unvote_for votable
          assert_true votable.votes_for_dataset.none?
        end

        self.focus if focus
        it 'removes a down vote' do
          voter.vote_down_for votable
          assert_true voter.unvote_for votable
          assert_true votable.votes_for_dataset.none?
        end

        self.focus if focus
        it 'sets vote_registered? to false' do
          voter.vote_for votable
          assert_true voter.unvote_for votable
          assert_false votable.vote_registered?
        end

        self.focus if focus
        it 'removes only a single vote' do
          voter.vote_up_for votable
          voter2.vote_up_for votable
          voter.unvote_for votable
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

      describe '#voted_for?' do
        self.focus if focus
        it 'is true if the user voted up' do
          voter.vote_up_for votable
          assert_true voter.voted_for?(votable)
        end

        self.focus if focus
        it 'is true if the user voted down' do
          voter.vote_down_for votable
          assert_true voter.voted_for?(votable)
        end

        self.focus if focus
        it 'is false if the user has not voted' do
          assert_false voter.voted_for?(votable)
        end

        self.focus if focus
        it 'is true if the user voted in scope' do
          voter.vote_up_for votable, vote_scope: 'rank'
          assert_false voter.voted_for?(votable)
          assert_true voter.voted_for?(votable, vote_scope: 'rank')
        end
      end

      describe '#voted_up_on?, #voted_down_on?' do
        self.focus if focus
        it 'is up if the user voted up' do
          voter.vote_up_for votable
          assert_true voter.voted_up_on?(votable)
          assert_false voter.voted_down_on?(votable)
        end

        self.focus if focus
        it 'is true if the user voted down' do
          voter.vote_down_for votable
          assert_false voter.voted_up_on?(votable)
          assert_true voter.voted_down_on?(votable)
        end

        self.focus if focus
        it 'is false if the user has not voted' do
          assert_false voter.voted_up_on?(votable)
          assert_false voter.voted_down_on?(votable)
        end

        self.focus if focus
        it 'is true if the user voted in scope' do
          voter.vote_up_for votable, vote_scope: 'rank'
          assert_false voter.voted_up_on?(votable)
          assert_false voter.voted_down_on?(votable)
          assert_true voter.voted_up_on?(votable, vote_scope: 'rank')
          assert_false voter.voted_down_on?(votable, vote_scope: 'rank')
        end
      end

      describe '#voted_as_when_voted_on' do
        self.focus if focus
        it 'is true when voted up' do
          voter.vote_up_for votable
          assert_true voter.voted_as_when_voted_on(votable)
        end

        self.focus if focus
        it 'is false when voted down' do
          voter.vote_down_for votable
          assert_false voter.voted_as_when_voted_on(votable)
        end

        self.focus if focus
        it 'is nil when not voted' do
          assert_nil voter.voted_as_when_voted_on(votable)
        end

        self.focus if focus
        it 'is true when voted up with a scope' do
          voter.vote_up_for votable, vote_scope: 'rank'
          assert_true voter.voted_as_when_voted_on(votable, vote_scope: 'rank')
          assert_nil voter.voted_as_when_voted_on(votable)
        end

        self.focus if focus
        it 'is false when voted down' do
          voter.vote_down_for votable, vote_scope: 'rank'
          assert_false voter.voted_as_when_voted_on(votable, vote_scope: 'rank')
          assert_nil voter.voted_as_when_voted_on(votable)
        end

        self.focus if focus
        it 'is nil when not voted' do
          assert_nil voter.voted_as_when_voted_on(votable, vote_scope: 'rank')
        end

        self.focus if focus
        it 'applies only to the voter' do
          voter.vote_down_for votable
          voter2.vote_up_for votable
          assert_false voter.voted_as_when_voted_on(votable)
        end
      end

      describe '#up_votes' do
        self.focus if focus
        it 'returns the set of up votes' do
          voter.vote_up_for votable
          voter.vote_up_for sti_votable
          voter.vote_down_for child_of_sti_votable
          voter.vote_down_for votable_child_of_sti_not_votable

          assert_equal [ votable.votes_for.first, sti_votable.votes_for.first ],
            voter.up_votes_by.all
        end
      end

      describe '#down_votes' do
        self.focus if focus
        it 'returns the set of down votes' do
          voter.vote_up_for votable
          voter.vote_up_for sti_votable
          voter.vote_down_for child_of_sti_votable
          voter.vote_down_for votable_child_of_sti_not_votable

          assert_equal [
            child_of_sti_votable.votes_for.first,
            votable_child_of_sti_not_votable.votes_for.first
          ], voter.down_votes_by.all
        end
      end

      describe '#votes_for_class' do
        self.focus if focus
        it 'returns the set of votes for this class' do
          voter.vote_up_for votable
          voter.vote_down_for votable2

          assert_equal [ votable.votes_for.first, votable2.votes_for.first ],
            voter.votes_for_class(votable.class).all
        end
      end

      describe '#up_votes_for_class' do
        self.focus if focus
        it 'returns the set of up votes for this class' do
          voter.vote_up_for votable
          voter.vote_down_for votable2

          assert_equal [ votable.votes_for.first ],
            voter.up_votes_for_class(votable.class).all
        end
      end

      describe '#down_votes_for_class' do
        self.focus if focus
        it 'returns the set of down votes for this class' do
          voter.vote_up_for votable
          voter.vote_down_for votable2

          assert_equal [ votable2.votes_for.first ],
            voter.down_votes_for_class(votable.class).all
        end
      end

      describe '#votables' do
        self.focus if focus
        it 'returns the set of items voted on' do
          voter.vote_up_for votable
          voter.vote_down_for votable2

          assert_equal [ votable, votable2 ], voter.votables
        end
      end

      describe '#up_votables' do
        self.focus if focus
        it 'returns the set of items up voted' do
          voter.vote_up_for votable
          voter.vote_down_for votable2

          assert_equal [ votable ], voter.up_votables
        end
      end

      describe '#down_votables' do
        self.focus if focus
        it 'returns the set of items down voted' do
          voter.vote_up_for votable
          voter.vote_down_for votable2

          assert_equal [ votable2 ], voter.down_votables
        end
      end
    end
  end

  ::Minitest::Test.extend self
end
