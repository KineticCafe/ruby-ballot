# frozen_string_literal: true

module VoterExamples
  def describe_voter_models(models, focus: false)
    describe '.ballot_voter?' do
      models.each do |model|
        self.focus if focus && respond_to?(:focus)
        it "#{model}.ballot_voter? is true" do
          assert_true model.ballot_voter?
        end

        self.focus if focus && respond_to?(:focus)
        it "#{model}#ballot_voter? is true" do
          assert_true model.new.ballot_voter?
        end
      end
    end
  end

  def describe_non_voter_models(models, focus: false)
    describe '.ballot_voter?' do
      models.each do |model|
        self.focus if focus && respond_to?(:focus)
        it "#{model}.ballot_voter? is false" do
          assert_false model.ballot_voter?
        end

        self.focus if focus && respond_to?(:focus)
        it "#{model}.ballot_voter? is false" do
          assert_false model.new.ballot_voter?
        end
      end
    end
  end

  def describe_ballot_voter(klass = nil, focus: false, &block)
    msg = 'a voter model'
    klass && msg = "#{klass} is #{msg}"

    describe msg do
      instance_exec(&block) if block

      describe '#cast_ballot_for' do
        self.focus if focus
        it 'is false when no votable is provided' do
          assert_false voter.cast_ballot_for
        end

        self.focus if focus
        it 'is false when the votable is not a model' do
          assert_false voter.cast_ballot_for Class.new
        end

        self.focus if focus
        it 'is false when the votable is not a votable' do
          assert_false voter.cast_ballot_for not_votable
        end

        self.focus if focus
        it 'is true when a vote succeeds' do
          assert_true voter.cast_ballot_for votable
        end

        self.focus if focus
        it 'adds a vote' do
          assert_true voter.cast_ballot_for votable
          assert_true voter_dataset(voter).any?
          assert_equal 1, voter_dataset(voter).count
        end

        self.focus if focus
        it 'creates only one vote per item' do
          voter.cast_ballot_for votable: votable

          assert_true(
            voter.cast_ballot_for(
              votable_id: votable.id,
              votable_type: ballot_type_name(votable),
              vote: 'no'
            )
          )

          assert_equal 1, votable_dataset(votable).count
        end

        self.focus if focus
        it 'creates only one vote per item, unless duplicates are allowed' do
          voter.cast_ballot_for votable: votable
          assert_true voter.cast_ballot_for votable: votable, duplicate: true
          assert_equal 2, votable_dataset(votable).count
        end

        self.focus if focus
        it 'creates a scoped vote' do
          voter.cast_ballot_for votable: votable, scope: 'rank'
          assert_true votable_dataset(votable).where(scope: 'rank').any?
        end

        self.focus if focus
        it 'creates only one scoped vote per person' do
          voter.cast_ballot_for votable: votable, scope: 'rank'
          voter.cast_ballot_for votable: votable, scope: 'rank', vote: 'no'
          assert_equal 1, votable_dataset(votable).where(scope: 'rank').count
        end

        self.focus if focus
        it 'creates only one scoped vote per person, unless duplicates are allowed' do
          voter.cast_ballot_for votable: votable, scope: 'rank'
          assert_true(
            voter.cast_ballot_for(
              votable: votable, scope: 'rank', vote: 'no', duplicate: true
            )
          )
          assert_equal 2, votable_dataset(votable).where(scope: 'rank').count
        end

        self.focus if focus
        it 'creates multiple votes with different scopes' do
          assert_true voter.cast_ballot_for votable: votable, scope: 'weekly_rank'
          assert_true voter.cast_ballot_for votable: votable, scope: 'monthly_rank'
          assert_equal 2, votable_dataset(votable).count
        end

        self.focus if focus
        it 'records separate votes for separate voters' do
          assert_true voter.cast_ballot_for votable: votable
          assert_true voter2.cast_ballot_for votable: votable
          assert_equal 2, votable_dataset(votable).count
        end

        self.focus if focus
        it 'uses a default vote weight of 1' do
          voter.cast_ballot_for votable
          assert_equal 1, votable_dataset(votable).first.weight
        end
      end

      describe '#cast_up_ballot_for' do
        self.focus if focus
        it 'is false when the votable is not a model' do
          assert_false voter.cast_up_ballot_for Class.new
        end

        self.focus if focus
        it 'is false when the votable is not a votable' do
          assert_false voter.cast_up_ballot_for not_votable
        end

        self.focus if focus
        it 'is true when a vote succeeds' do
          assert_true voter.cast_up_ballot_for votable
        end

        self.focus if focus
        it 'adds a vote' do
          assert_true voter.cast_up_ballot_for votable
          assert_true voter_dataset(voter).any?
          assert_equal 1, votable_dataset(votable).count
        end

        self.focus if focus
        it 'creates only one vote per item' do
          voter.cast_up_ballot_for votable
          assert_false voter.cast_up_ballot_for votable, vote: 'no'
          assert_equal 1, votable_dataset(votable).count
        end

        self.focus if focus
        it 'creates only one vote per item, unless duplicates are allowed' do
          voter.cast_up_ballot_for votable
          assert_true voter.cast_up_ballot_for votable, duplicate: true
          assert_equal 2, votable_dataset(votable).count
        end

        self.focus if focus
        it 'creates a scoped vote' do
          voter.cast_up_ballot_for votable, scope: 'rank'
          assert_true votable_dataset(votable).where(scope: 'rank').any?
        end

        self.focus if focus
        it 'creates only one scoped vote per person' do
          voter.cast_up_ballot_for votable, scope: 'rank'
          voter.cast_up_ballot_for votable, scope: 'rank', vote: 'no'
          assert_equal 1, votable_dataset(votable).where(scope: 'rank').count
        end

        self.focus if focus
        it 'creates only one scoped vote per person, unless duplicates are allowed' do
          voter.cast_up_ballot_for votable, scope: 'rank'
          assert_true(
            voter.cast_up_ballot_for(votable, scope: 'rank', vote: 'no', duplicate: true)
          )
          assert_equal 2, votable_dataset(votable).where(scope: 'rank').count
        end

        self.focus if focus
        it 'creates multiple votes with different scopes' do
          assert_true voter.cast_up_ballot_for votable, scope: 'weekly_rank'
          assert_true voter.cast_up_ballot_for votable, scope: 'monthly_rank'
          assert_equal 2, votable_dataset(votable).count
        end

        self.focus if focus
        it 'records separate votes for separate voters' do
          assert_true voter.cast_up_ballot_for votable
          assert_true voter2.cast_up_ballot_for votable
          assert_equal 2, votable_dataset(votable).count
        end

        self.focus if focus
        it 'uses a default vote weight of 1' do
          voter.cast_up_ballot_for votable
          assert_equal 1, votable_dataset(votable).first.weight
        end
      end

      describe '#cast_down_ballot_for' do
        self.focus if focus
        it 'is false when the votable is not a model' do
          assert_false voter.cast_down_ballot_for Class.new
        end

        self.focus if focus
        it 'is false when the votable is not a votable' do
          assert_false voter.cast_down_ballot_for not_votable
        end

        self.focus if focus
        it 'is true when a vote succeeds' do
          assert_true voter.cast_down_ballot_for votable
        end

        self.focus if focus
        it 'adds a vote' do
          assert_true voter.cast_down_ballot_for votable
          assert_true voter_dataset(voter).any?
          assert_equal 1, votable_dataset(votable).count
        end

        self.focus if focus
        it 'creates only one vote per item' do
          voter.cast_down_ballot_for votable
          assert_false voter.cast_down_ballot_for votable, vote: 'no'
          assert_equal 1, votable_dataset(votable).count
        end

        self.focus if focus
        it 'creates only one vote per item, unless duplicates are allowed' do
          voter.cast_down_ballot_for votable
          assert_true voter.cast_down_ballot_for votable, duplicate: true
          assert_equal 2, votable_dataset(votable).count
        end

        self.focus if focus
        it 'creates a scoped vote' do
          voter.cast_down_ballot_for votable, scope: 'rank'
          assert_true votable_dataset(votable).where(scope: 'rank').any?
        end

        self.focus if focus
        it 'creates only one scoped vote per person' do
          voter.cast_down_ballot_for votable, scope: 'rank'
          voter.cast_down_ballot_for votable, scope: 'rank', vote: 'no'
          assert_equal 1, votable_dataset(votable).where(scope: 'rank').count
        end

        self.focus if focus
        it 'creates only one scoped vote per person, unless duplicates are allowed' do
          voter.cast_down_ballot_for votable, scope: 'rank'
          assert_true(
            voter.cast_down_ballot_for(votable, scope: 'rank', vote: 'no', duplicate: true)
          )
          assert_equal 2, votable_dataset(votable).where(scope: 'rank').count
        end

        self.focus if focus
        it 'creates multiple votes with different scopes' do
          assert_true voter.cast_down_ballot_for votable, scope: 'weekly_rank'
          assert_true voter.cast_down_ballot_for votable, scope: 'monthly_rank'
          assert_equal 2, votable_dataset(votable).count
        end

        self.focus if focus
        it 'records separate votes for separate voters' do
          assert_true voter.cast_down_ballot_for votable
          assert_true voter2.cast_down_ballot_for votable
          assert_equal 2, votable_dataset(votable).count
        end

        self.focus if focus
        it 'uses a default vote weight of 1' do
          voter.cast_down_ballot_for votable
          assert_equal 1, votable_dataset(votable).first.weight
        end
      end

      describe '#remove_ballot_for' do
        self.focus if focus
        it 'removes an up vote' do
          voter.cast_up_ballot_for votable
          assert_true voter.remove_ballot_for votable
          assert_true votable_dataset(votable).none?
        end

        self.focus if focus
        it 'removes a down vote' do
          voter.cast_down_ballot_for votable
          assert_true voter.remove_ballot_for votable
          assert_true votable_dataset(votable).none?
        end

        self.focus if focus
        it 'sets ballot_registered? to false' do
          voter.cast_ballot_for votable
          assert_true voter.remove_ballot_for votable
          assert_false votable.ballot_registered?
        end

        self.focus if focus
        it 'removes only a single vote' do
          voter.cast_up_ballot_for votable
          voter2.cast_up_ballot_for votable
          voter.remove_ballot_for votable
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

      describe '#cast_ballot_for?' do
        self.focus if focus
        it 'is true if the user voted up' do
          voter.cast_up_ballot_for votable
          assert_true voter.cast_ballot_for?(votable)
        end

        self.focus if focus
        it 'is true if the user voted down' do
          voter.cast_down_ballot_for votable
          assert_true voter.cast_ballot_for?(votable)
        end

        self.focus if focus
        it 'is false if the user has not voted' do
          assert_false voter.cast_ballot_for?(votable)
        end

        self.focus if focus
        it 'is true if the user voted in scope' do
          voter.cast_up_ballot_for votable, scope: 'rank'
          assert_false voter.cast_ballot_for?(votable)
          assert_true voter.cast_ballot_for?(votable, scope: 'rank')
        end
      end

      describe '#cast_up_ballot_for?, #cast_down_ballot_for?' do
        self.focus if focus
        it 'is up if the user voted up' do
          voter.cast_up_ballot_for votable
          assert_true voter.cast_up_ballot_for?(votable)
          assert_false voter.cast_down_ballot_for?(votable)
        end

        self.focus if focus
        it 'is true if the user voted down' do
          voter.cast_down_ballot_for votable
          assert_false voter.cast_up_ballot_for?(votable)
          assert_true voter.cast_down_ballot_for?(votable)
        end

        self.focus if focus
        it 'is false if the user has not voted' do
          assert_false voter.cast_up_ballot_for?(votable)
          assert_false voter.cast_down_ballot_for?(votable)
        end

        self.focus if focus
        it 'is true if the user voted in scope' do
          voter.cast_up_ballot_for votable, scope: 'rank'
          assert_false voter.cast_up_ballot_for?(votable)
          assert_false voter.cast_down_ballot_for?(votable)
          assert_true voter.cast_up_ballot_for?(votable, scope: 'rank')
          assert_false voter.cast_down_ballot_for?(votable, scope: 'rank')
        end
      end

      describe '#ballot_as_cast_for' do
        self.focus if focus
        it 'is true when voted up' do
          voter.cast_up_ballot_for votable
          assert_true voter.ballot_as_cast_for(votable)
        end

        self.focus if focus
        it 'is false when voted down' do
          voter.cast_down_ballot_for votable
          assert_false voter.ballot_as_cast_for(votable)
        end

        self.focus if focus
        it 'is nil when not voted' do
          assert_nil voter.ballot_as_cast_for(votable)
        end

        self.focus if focus
        it 'is true when voted up with a scope' do
          voter.cast_up_ballot_for votable, scope: 'rank'
          assert_true voter.ballot_as_cast_for(votable, scope: 'rank')
          assert_nil voter.ballot_as_cast_for(votable)
        end

        self.focus if focus
        it 'is false when voted down' do
          voter.cast_down_ballot_for votable, scope: 'rank'
          assert_false voter.ballot_as_cast_for(votable, scope: 'rank')
          assert_nil voter.ballot_as_cast_for(votable)
        end

        self.focus if focus
        it 'is nil when not voted' do
          assert_nil voter.ballot_as_cast_for(votable, scope: 'rank')
        end

        self.focus if focus
        it 'applies only to the voter' do
          voter.cast_down_ballot_for votable
          voter2.cast_up_ballot_for votable
          assert_false voter.ballot_as_cast_for(votable)
        end
      end

      describe '#up_ballots_by' do
        self.focus if focus
        it 'returns the set of up votes' do
          voter.cast_up_ballot_for votable
          voter.cast_up_ballot_for sti_votable
          voter.cast_down_ballot_for child_of_sti_votable
          voter.cast_down_ballot_for votable_child_of_sti_not_votable

          assert_equal [
            votable_dataset(votable).first,
            votable_dataset(sti_votable).first
          ], voter.up_ballots_by.all
        end
      end

      describe '#down_ballots_by' do
        self.focus if focus
        it 'returns the set of down votes' do
          voter.cast_up_ballot_for votable
          voter.cast_up_ballot_for sti_votable
          voter.cast_down_ballot_for child_of_sti_votable
          voter.cast_down_ballot_for votable_child_of_sti_not_votable

          assert_equal [
            votable_dataset(child_of_sti_votable).first,
            votable_dataset(votable_child_of_sti_not_votable).first
          ], voter.down_ballots_by.all
        end
      end

      describe '#ballots_for_class' do
        self.focus if focus
        it 'returns the set of votes for this class' do
          voter.cast_up_ballot_for votable
          voter.cast_down_ballot_for votable2

          assert_equal [ votable_dataset(votable).first, votable_dataset(votable2).first ],
            voter.ballots_for_class(votable.class).all
        end
      end

      describe '#up_ballots_for_class' do
        self.focus if focus
        it 'returns the set of up votes for this class' do
          voter.cast_up_ballot_for votable
          voter.cast_down_ballot_for votable2

          assert_equal [ votable_dataset(votable).first ],
            voter.up_ballots_for_class(votable.class).all
        end
      end

      describe '#down_ballots_for_class' do
        self.focus if focus
        it 'returns the set of down votes for this class' do
          voter.cast_up_ballot_for votable
          voter.cast_down_ballot_for votable2

          assert_equal [ votable_dataset(votable2).first ],
            voter.down_ballots_for_class(votable.class).all
        end
      end

      describe '#ballot_votables' do
        self.focus if focus
        it 'returns the set of items voted on' do
          voter.cast_up_ballot_for votable
          voter.cast_down_ballot_for votable2

          assert_equal [ votable, votable2 ], voter.ballot_votables
        end
      end

      describe '#ballot_up_votables' do
        self.focus if focus
        it 'returns the set of items up voted' do
          voter.cast_up_ballot_for votable
          voter.cast_down_ballot_for votable2

          assert_equal [ votable ], voter.ballot_up_votables
        end
      end

      describe '#ballot_down_votables' do
        self.focus if focus
        it 'returns the set of items down voted' do
          voter.cast_up_ballot_for votable
          voter.cast_down_ballot_for votable2

          assert_equal [ votable2 ], voter.ballot_down_votables
        end
      end
    end
  end

  def describe_ballot_voter_sti_votable_support(focus: false)
    describe 'with STI' do
      describe '#vote' do
        self.focus if focus && respond_to?(:focus)
        it 'works with STI models' do
          voter.cast_ballot_for sti_votable
          assert_true votable_dataset(sti_votable).any?
        end

        self.focus if focus && respond_to?(:focus)
        it 'works with Child STI models' do
          voter.cast_ballot_for child_of_sti_votable
          assert_true votable_dataset(child_of_sti_votable).any?
        end

        self.focus if focus && respond_to?(:focus)
        it 'works with votable children of non-votable STI models' do
          voter.cast_ballot_for votable_child_of_sti_not_votable
          assert_true votable_dataset(votable_child_of_sti_not_votable).any?
        end
      end

      describe '#cast_up_ballot_for' do
        self.focus if focus && respond_to?(:focus)
        it 'works with STI models' do
          voter.cast_up_ballot_for sti_votable
          assert_true votable_dataset(sti_votable).any?
        end

        self.focus if focus && respond_to?(:focus)
        it 'works with Child STI models' do
          voter.cast_up_ballot_for child_of_sti_votable
          assert_true votable_dataset(child_of_sti_votable).any?
        end

        self.focus if focus && respond_to?(:focus)
        it 'works with votable children of non-votable STI models' do
          voter.cast_up_ballot_for votable_child_of_sti_not_votable
          assert_true votable_dataset(votable_child_of_sti_not_votable).any?
        end
      end

      describe '#cast_down_ballot_for' do
        self.focus if focus && respond_to?(:focus)
        it 'works with STI models' do
          voter.cast_down_ballot_for sti_votable
          assert_true votable_dataset(sti_votable).any?
        end

        self.focus if focus && respond_to?(:focus)
        it 'works with Child STI models' do
          voter.cast_down_ballot_for child_of_sti_votable
          assert_true votable_dataset(child_of_sti_votable).any?
        end

        self.focus if focus && respond_to?(:focus)
        it 'works with votable children of non-votable STI models' do
          voter.cast_down_ballot_for votable_child_of_sti_not_votable
          assert_true votable_dataset(votable_child_of_sti_not_votable).any?
        end
      end
    end
  end

  ::Minitest::SequelSpec.extend self
  ::Minitest::ActiveRecordSpec.extend self
end
