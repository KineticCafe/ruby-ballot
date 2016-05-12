# frozen_string_literal: true

module VotableExamples
  def describe_votable_models(models, focus: false)
    describe '.ballot_votable?' do
      models.each do |model|
        self.focus if focus && respond_to?(:focus)
        it "#{model}.ballot_votable? is true" do
          assert_true model.ballot_votable?
        end

        self.focus if focus && respond_to?(:focus)
        it "#{model}#ballot_votable? is true" do
          assert_true model.new.ballot_votable?
        end
      end
    end
  end

  def describe_non_votable_models(models, focus: false)
    describe '.ballot_votable?' do
      models.each do |model|
        self.focus if focus && respond_to?(:focus)
        it "#{model}.ballot_votable? is false" do
          assert_false model.ballot_votable?
        end

        self.focus if focus && respond_to?(:focus)
        it "#{model}.ballot_votable? is false" do
          assert_false model.new.ballot_votable?
        end
      end
    end
  end

  def describe_ballot_votable(klass = nil, focus: false, &block)
    msg = 'a votable model'
    klass && msg = "#{klass} is #{msg}"

    describe msg do
      instance_exec(&block) if block

      describe '#ballot_by' do
        self.focus if focus && respond_to?(:focus)
        it 'is false when no voter is provided' do
          assert_false votable.ballot_by
        end

        self.focus if focus && respond_to?(:focus)
        it 'is false when the voter is not a model' do
          assert_false votable.ballot_by voter: Class.new
        end

        self.focus if focus && respond_to?(:focus)
        it 'is false when the voter is not a voter' do
          assert_false votable.ballot_by voter: not_voter
        end

        self.focus if focus && respond_to?(:focus)
        it 'creates a vote' do
          assert_true votable.ballot_by voter: voter
          assert_true votable.ballots_for.any?
          assert_equal(1, votable_dataset(votable).count)
        end

        self.focus if focus && respond_to?(:focus)
        it 'creates only one vote per person' do
          assert_true votable.ballot_by voter: voter, vote: 'yes'
          assert_true votable.ballot_by voter: voter, vote: 'no'
          assert_equal(1, votable_dataset(votable).count)
        end

        self.focus if focus && respond_to?(:focus)
        it 'creates only one vote per person, unless duplicates are allowed' do
          assert_true votable.ballot_by voter: voter, vote: 'yes'
          assert_true votable.ballot_by voter: voter, vote: 'no', duplicate: true
          assert_equal(2, votable_dataset(votable).count)
        end

        self.focus if focus && respond_to?(:focus)
        it 'creates a scoped vote' do
          assert_true votable.ballot_by voter: voter, scope: 'rank'
          assert_true votable_dataset(votable).where(scope: 'rank').any?
        end

        self.focus if focus && respond_to?(:focus)
        it 'creates only one scoped vote per person' do
          assert_true votable.ballot_by voter: voter, scope: 'rank'
          assert_true votable.ballot_by voter: voter, scope: 'rank', vote: 'no'
          assert_equal(1, votable_dataset(votable).where(scope: 'rank').count)
        end

        self.focus if focus && respond_to?(:focus)
        it 'creates only one scoped vote per person, unless duplicates are allowed' do
          assert_true votable.ballot_by voter: voter, scope: 'rank'
          assert_true(
            votable.ballot_by(voter: voter, scope: 'rank', vote: 'no', duplicate: true)
          )
          assert_equal(2, votable_dataset(votable).where(scope: 'rank').count)
        end

        self.focus if focus && respond_to?(:focus)
        it 'creates multiple votes with different scopes' do
          assert_true votable.ballot_by voter: voter, scope: 'weekly_rank'
          assert_true votable.ballot_by voter: voter, scope: 'monthly_rank'
          assert_equal(2, votable_dataset(votable).count)
        end

        self.focus if focus && respond_to?(:focus)
        it 'records separate votes for separate voters' do
          assert_true votable.ballot_by voter: voter
          assert_true votable.ballot_by voter: voter2
          assert_equal(2, votable_dataset(votable).count)
        end

        self.focus if focus && respond_to?(:focus)
        it 'uses a default vote weight of 1' do
          votable.up_ballot_by voter
          assert_equal(1, votable_dataset(votable).first.weight)
        end
      end

      describe '#up_ballot_by' do
        self.focus if focus && respond_to?(:focus)
        it 'creates an up vote for the user' do
          assert_true votable.up_ballot_by voter
          assert_true votable_dataset(votable).where(
            voter_id: voter.id,
            voter_type: voter.class.name,
            vote: true
          ).any?
        end
      end

      describe '#down_ballot_by' do
        self.focus if focus && respond_to?(:focus)
        it 'creates a down vote for the user' do
          assert_true votable.down_ballot_by voter
          assert_true votable_dataset(votable).where(
            voter_id: voter.id,
            voter_type: voter.class.name,
            vote: false
          ).any?
        end
      end

      describe '#up_ballots_for' do
        self.focus if focus && respond_to?(:focus)
        it 'includes only positive votes' do
          votable.up_ballot_by voter
          votable.down_ballot_by voter2
          assert_equal(1, votable.up_ballots_for.count)
          assert_true votable.up_ballots_for.
            where(voter_id: voter.id, voter_type: voter.class.name).any?
        end
      end

      describe '#down_ballots_for' do
        self.focus if focus && respond_to?(:focus)
        it 'includes only positive votes' do
          votable.up_ballot_by voter
          votable.down_ballot_by voter2
          assert_equal(1, votable.down_ballots_for.count)
          assert_true votable.down_ballots_for.
            where(voter_id: voter2.id, voter_type: voter2.class.name).any?
        end
      end

      describe '#ballot_registered?' do
        self.focus if focus && respond_to?(:focus)
        it 'counts the vote as registered for the first vote' do
          assert_true votable.up_ballot_by voter
          assert_true votable.ballot_registered?
        end

        self.focus if focus && respond_to?(:focus)
        it 'does not count a second unchanged vote as registered' do
          assert_true votable.up_ballot_by voter
          assert_false votable.up_ballot_by voter
          assert_false votable.ballot_registered?
        end

        self.focus if focus && respond_to?(:focus)
        it 'counts changed votes as registered' do
          assert_true votable.up_ballot_by voter
          assert_true votable.down_ballot_by voter
          assert_true votable.ballot_registered?
        end

        self.focus if focus && respond_to?(:focus)
        it 'counts vote weight changes as registered' do
          assert_true votable.up_ballot_by voter
          assert_true votable.up_ballot_by voter, weight: 2
          assert_true votable.ballot_registered?
        end

        self.focus if focus && respond_to?(:focus)
        it 'belongs only to a particular instance' do
          votable.down_ballot_by voter
          votable2 = votable.dup
          votable2.up_ballot_by voter
          votable2.up_ballot_by voter

          assert_true votable.ballot_registered?
          assert_false votable2.ballot_registered?
        end
      end

      describe '#ballot_by?' do
        self.focus if focus && respond_to?(:focus)
        it 'is true if the user voted' do
          assert_true votable.up_ballot_by voter
          assert_true votable.ballot_by?(voter)
          assert_true votable.down_ballot_by voter
          assert_true votable.ballot_by?(voter)
        end

        self.focus if focus && respond_to?(:focus)
        it 'is false if the user did not vote' do
          assert_false votable.ballot_by?(voter)
        end
      end

      describe '#up_ballot_by?' do
        self.focus if focus && respond_to?(:focus)
        it 'is true if the user voted up' do
          assert_true votable.up_ballot_by voter
          assert_true votable.up_ballot_by?(voter)
        end

        self.focus if focus && respond_to?(:focus)
        it 'is false if the user did not vote' do
          assert_false votable.up_ballot_by?(voter)
        end

        it 'is false if the user voted down' do
          assert_true votable.down_ballot_by voter
          assert_false votable.up_ballot_by?(voter)
        end
      end

      describe '#down_ballot_by?' do
        self.focus if focus && respond_to?(:focus)
        it 'is true if the user voted down' do
          assert_true votable.down_ballot_by voter
          assert_true votable.down_ballot_by?(voter)
        end

        self.focus if focus && respond_to?(:focus)
        it 'is false if the user did not vote' do
          assert_false votable.down_ballot_by?(voter)
        end

        it 'is false if the user voted up' do
          assert_true votable.up_ballot_by voter
          assert_false votable.down_ballot_by?(voter)
        end
      end

      describe '#remove_ballot_by' do
        self.focus if focus && respond_to?(:focus)
        it 'removes an up vote' do
          assert_true votable.up_ballot_by voter
          assert_true votable.remove_ballot_by voter: voter
          assert_true votable_dataset(votable).none?
        end

        self.focus if focus && respond_to?(:focus)
        it 'removes a down vote' do
          assert_true votable.down_ballot_by voter
          assert_true votable.remove_ballot_by voter: voter
          assert_true votable_dataset(votable).none?
        end

        self.focus if focus && respond_to?(:focus)
        it 'sets ballot_registered? to false' do
          assert_true votable.up_ballot_by voter
          assert_true votable.remove_ballot_by voter: voter
          assert_false votable.ballot_registered?
        end

        self.focus if focus && respond_to?(:focus)
        it 'removes only a single vote' do
          assert_true votable.up_ballot_by voter
          assert_true votable.up_ballot_by voter2
          assert_true votable.remove_ballot_by voter: voter
          assert_true votable_dataset(votable).any?
          assert_true votable_dataset(votable).where(
            voter_id: voter.id,
            voter_type: voter.class.name
          ).none?
          assert_true votable_dataset(votable).where(
            voter_id: voter2.id,
            voter_type: voter2.class.name
          ).any?
        end
      end

      describe '#remove_ballot_by' do
        self.focus if focus && respond_to?(:focus)
        it 'removes an up vote' do
          assert_true votable.up_ballot_by voter
          assert_true votable.remove_ballot_by voter
          assert_true votable_dataset(votable).none?
        end

        self.focus if focus && respond_to?(:focus)
        it 'removes a down vote' do
          assert_true votable.down_ballot_by voter
          assert_true votable.remove_ballot_by voter
          assert_true votable_dataset(votable).none?
        end

        self.focus if focus && respond_to?(:focus)
        it 'sets ballot_registered? to false' do
          assert_true votable.up_ballot_by voter
          assert_true votable.remove_ballot_by voter
          assert_false votable.ballot_registered?
        end

        self.focus if focus && respond_to?(:focus)
        it 'removes only a single vote' do
          assert_true votable.up_ballot_by voter
          assert_true votable.up_ballot_by voter2
          assert_true votable.remove_ballot_by voter
          assert_true votable_dataset(votable).any?
          assert_true votable_dataset(votable).where(
            voter_id: voter.id,
            voter_type: voter.class.name
          ).none?
          assert_true votable_dataset(votable).where(
            voter_id: voter2.id,
            voter_type: voter2.class.name
          ).any?
        end
      end

      describe '#ballots_by_class' do
        self.focus if focus
        it 'returns the set of votes by this class' do
          voter.cast_up_ballot_for votable
          voter2.cast_down_ballot_for votable

          assert_equal [ voter_dataset(voter).first, voter_dataset(voter2).first ],
            votable.ballots_by_class(voter.class).all
        end
      end

      describe '#up_ballots_by_class' do
        self.focus if focus
        it 'returns the set of up votes for this class' do
          voter.cast_up_ballot_for votable
          voter2.cast_down_ballot_for votable

          assert_equal [ voter_dataset(voter).first ],
            votable.up_ballots_by_class(voter.class).all
        end
      end

      describe '#down_ballots_by_class' do
        self.focus if focus
        it 'returns the set of down votes for this class' do
          voter.cast_up_ballot_for votable
          voter2.cast_down_ballot_for votable

          assert_equal [ voter_dataset(voter2).first ],
            votable.down_ballots_by_class(voter.class).all
        end
      end

      describe '#ballot_voters' do
        self.focus if focus && respond_to?(:focus)
        it 'returns the set of voters' do
          votable.up_ballot_by voter
          votable.down_ballot_by voter2

          assert_equal [ voter, voter2 ], votable.ballot_voters
        end
      end

      describe '#up_ballot_voters' do
        self.focus if focus && respond_to?(:focus)
        it 'returns the set of voters' do
          votable.up_ballot_by voter
          votable.down_ballot_by voter2

          assert_equal [ voter ], votable.up_ballot_voters
        end
      end

      describe '#down_ballot_voters' do
        self.focus if focus && respond_to?(:focus)
        it 'returns the set of voters' do
          votable.up_ballot_by voter
          votable.down_ballot_by voter2

          assert_equal [ voter2 ], votable.down_ballot_voters
        end
      end
    end
  end

  def describe_ballot_votable_sti_support(focus: false)
    describe 'STI support' do
      describe '#ballot_by' do
        self.focus if focus && respond_to?(:focus)
        it 'works with STI models' do
          sti_votable.ballot_by voter: voter
          assert_true votable_dataset(sti_votable).any?
        end

        self.focus if focus && respond_to?(:focus)
        it 'works with Child STI models' do
          child_of_sti_votable.ballot_by voter: voter
          assert_true child_of_sti_votable.ballots_for.any?
        end

        self.focus if focus && respond_to?(:focus)
        it 'works with votable children of non-votable STI models' do
          votable_child_of_sti_not_votable.ballot_by voter: voter
          assert_true votable_child_of_sti_not_votable.ballots_for.any?
        end
      end
    end
  end

  def describe_cached_ballot_summary(using_model, focus: false)
    describe 'with cached_ballot_summary' do
      self.focus if focus && respond_to?(:focus)
      it 'does not update cached votes summary if there is no summary column' do
        instance_stub using_model, :total_ballots do
          votable.up_ballot_by voter
        end

        assert_instance_called using_model, :total_ballots, 0
      end

      self.focus if focus && respond_to?(:focus)
      it 'updates the cached total' do
        assert_equal(0, votable_cache.total_ballots)

        votable_cache.up_ballot_by voter
        assert_equal(1, votable_cache.total_ballots)

        votable_cache.down_ballot_by voter2
        assert_equal(2, votable_cache.total_ballots)

        votable_cache.remove_ballot_by voter
        assert_equal(1, votable_cache.total_ballots)
      end

      self.focus if focus && respond_to?(:focus)
      it 'updates the cached up votes' do
        assert_equal(0, votable_cache.total_up_ballots)

        votable_cache.up_ballot_by voter
        assert_equal(1, votable_cache.total_up_ballots)

        votable_cache.down_ballot_by voter2
        assert_equal(1, votable_cache.total_up_ballots)
      end

      self.focus if focus && respond_to?(:focus)
      it 'downdates the cached down votes' do
        assert_equal(0, votable_cache.total_down_ballots)

        votable_cache.up_ballot_by voter
        assert_equal(0, votable_cache.total_down_ballots)

        votable_cache.down_ballot_by voter2
        assert_equal(1, votable_cache.total_down_ballots)
      end

      self.focus if focus && respond_to?(:focus)
      it 'updates the cached score' do
        assert_equal(0, votable_cache.ballot_score)

        votable_cache.down_ballot_by voter
        assert_equal(-1, votable_cache.ballot_score)

        votable_cache.down_ballot_by voter2
        assert_equal(-2, votable_cache.ballot_score)

        votable_cache.remove_ballot_by voter
        assert_equal(-1, votable_cache.ballot_score)
      end

      self.focus if focus && respond_to?(:focus)
      it 'updates the weighted total' do
        assert_equal(0, votable_cache.weighted_ballot_total)

        votable_cache.up_ballot_by voter
        assert_equal(1, votable_cache.weighted_ballot_total)

        votable_cache.down_ballot_by voter2, weight: 2
        assert_equal(3, votable_cache.weighted_ballot_total)

        votable_cache.remove_ballot_by voter
        assert_equal(2, votable_cache.weighted_ballot_total)
      end

      self.focus if focus && respond_to?(:focus)
      it 'updates the weighted score' do
        assert_equal(0, votable_cache.weighted_ballot_score)

        assert_true votable_cache.down_ballot_by voter
        assert_equal(-1, votable_cache.weighted_ballot_score)

        votable_cache.down_ballot_by voter2, weight: 2
        assert_equal(-3, votable_cache.weighted_ballot_score)

        votable_cache.remove_ballot_by voter
        assert_equal(-2, votable_cache.weighted_ballot_score)
      end

      describe 'under a scope' do
        self.focus if focus && respond_to?(:focus)
        it 'does not update cached votes summary if there is no summary column' do
          instance_stub using_model, :total_ballots do
            votable.up_ballot_by voter, scope: 'scoped'
          end

          assert_instance_called using_model, :total_ballots, 0
        end

        self.focus if focus && respond_to?(:focus)
        it 'does not affect the unscoped count' do
          assert_equal(0, votable_cache.total_ballots)

          votable_cache.up_ballot_by voter, scope: 'scoped'
          assert_equal(0, votable_cache.total_ballots)
        end

        self.focus if focus && respond_to?(:focus)
        it 'updates the cached total' do
          assert_equal(0, votable_cache.total_ballots('scoped'))

          votable_cache.up_ballot_by voter, scope: 'scoped'
          assert_equal(1, votable_cache.total_ballots('scoped'))

          votable_cache.down_ballot_by voter2, scope: 'scoped'
          assert_equal(2, votable_cache.total_ballots('scoped'))

          votable_cache.remove_ballot_by voter, scope: 'scoped'
          assert_equal(1, votable_cache.total_ballots('scoped'))
        end

        self.focus if focus && respond_to?(:focus)
        it 'updates the cached up votes' do
          assert_equal(0, votable_cache.total_up_ballots('scoped'))

          votable_cache.up_ballot_by voter, scope: 'scoped'
          assert_equal(1, votable_cache.total_up_ballots('scoped'))

          votable_cache.down_ballot_by voter2
          assert_equal(1, votable_cache.total_up_ballots('scoped'))
        end

        self.focus if focus && respond_to?(:focus)
        it 'downdates the cached down votes' do
          assert_equal(0, votable_cache.total_down_ballots('scoped'))

          votable_cache.up_ballot_by voter, scope: 'scoped'
          assert_equal(0, votable_cache.total_down_ballots('scoped'))

          assert_true votable_cache.down_ballot_by voter2, scope: 'scoped'
          assert_equal(1, votable_cache.total_down_ballots('scoped'))
        end

        self.focus if focus && respond_to?(:focus)
        it 'updates the cached score' do
          assert_equal(0, votable_cache.ballot_score('scoped'))

          votable_cache.down_ballot_by voter, scope: 'scoped'
          assert_equal(-1, votable_cache.ballot_score('scoped'))

          votable_cache.down_ballot_by voter2, scope: 'scoped'
          assert_equal(-2, votable_cache.ballot_score('scoped'))

          votable_cache.remove_ballot_by voter, scope: 'scoped'
          assert_equal(-1, votable_cache.ballot_score('scoped'))
        end

        self.focus if focus && respond_to?(:focus)
        it 'updates the weighted total' do
          assert_equal(0, votable_cache.weighted_ballot_total('scoped'))

          votable_cache.up_ballot_by voter, scope: 'scoped'
          assert_equal(1, votable_cache.weighted_ballot_total('scoped'))

          votable_cache.down_ballot_by voter2, weight: 2, scope: 'scoped'
          assert_equal(3, votable_cache.weighted_ballot_total('scoped'))

          votable_cache.remove_ballot_by voter, scope: 'scoped'
          assert_equal(2, votable_cache.weighted_ballot_total('scoped'))
        end

        self.focus if focus && respond_to?(:focus)
        it 'updates the weighted score' do
          assert_equal(0, votable_cache.weighted_ballot_score('scoped'))
          votable_cache.down_ballot_by voter, scope: 'scoped'
          assert_equal(-1, votable_cache.weighted_ballot_score('scoped'))

          votable_cache.down_ballot_by voter2, weight: 2, scope: 'scoped'
          assert_equal(-3, votable_cache.weighted_ballot_score('scoped'))

          votable_cache.remove_ballot_by voter, scope: 'scoped'
          assert_equal(-2, votable_cache.weighted_ballot_score('scoped'))
        end
      end

      self.focus if focus && respond_to?(:focus)
      it 'README example' do
        voter.cast_ballot_for votable, weight: 4
        voter2.cast_ballot_for votable, vote: false

        assert_equal(2, votable.total_ballots)
        assert_equal(1, votable.total_up_ballots)
        assert_equal(1, votable.total_down_ballots)
        assert_equal(0, votable.ballot_score)
        assert_equal(5, votable.weighted_ballot_total)
        assert_equal(3, votable.weighted_ballot_score)
        assert_in_delta(1.5, votable.weighted_ballot_average)
      end
    end
  end

  ::Minitest::SequelSpec.extend self
  ::Minitest::ActiveRecordSpec.extend self
end
