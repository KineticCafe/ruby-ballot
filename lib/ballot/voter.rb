# frozen_string_literal: true

##
module Ballot
  # Methods added to a model that is marked as a Voter.
  module Voter
    #-----
    # :section: Recording Votes
    #-----

    ##
    # :method: cast_ballot_for
    # :call-seq:
    #    cast_ballot_for(votable = nil, kwargs = {})
    #    cast_ballot_for(votable)
    #    cast_ballot_for(votable_id: id, votable_type: type)
    #    cast_ballot_for(votable_gid: gid)
    #    cast_ballot_for(votable, scope: scope, vote: false, weight: true)
    #
    # Record a Vote for this Voter on the provided +votable+. The +votable+ may
    # be specified as its own parameter, or through the keyword arguments
    # +votable_id+, +votable_type+, +votable_gid+, or +votable+ (note that the
    # parameter +votable+ will override the keyword argument +votable+, if both
    # are provided).
    #
    # Additional named arguments may be provided through +kwargs+:
    #
    # scope:: The scope of the vote to be recorded. Defaults to +nil+.
    # vote:: The vote to be recorded. Defaults to +true+ and is parsed through
    #        Ballot::Words.truthy?.
    # weight:: The weight of the vote to be recorded. Defaults to +1+.
    # duplicate:: Allow a duplicate vote to be recorded. This is not
    #             recommended as it has negative performance implications at
    #             scale.
    #
    # Other arguments are ignored.
    #
    # \ActiveRecord:: There are no special notes for ActiveRecord.
    # \Sequel:: GlobalID does not currently provide support for Sequel. The use
    #           of +votable_gid+ in this case will probably fail.
    #
    # <em>Also aliased as: #ballot_for.</em>

    ##
    # :method: ballot_for
    # :call-seq:
    #    ballot_for(votable = nil, kwargs = {})
    #    ballot_for(votable)
    #    ballot_for(votable_id: id, votable_type: type)
    #    ballot_for(votable_gid: gid)
    #    ballot_for(votable, scope: scope, vote: false, weight: true)
    #
    # <em>Alias for: #cast_ballot_for.</em>

    ##
    # Create, update, and remove votes for a lot of Votable objects in a single
    # transaction. All of the votes for the votables in +up+ or +down+ will be
    # set to the same weight and scope, and all of the votes for the votables
    # in +remove+ will be removed.
    #
    # The votables in +up+, +down+, and +remove+ can be described in several
    # ways:
    #
    # * as an Array of Votable objects;
    #       up: [ votable1, votable2, votable3 ]
    # * as an Array of Hashes with Votable type names to id;
    #       up: [ { Votable: 1 }, { Votable: 2 } ]
    # * as a Hash of Votable type names to an array of ids;
    #       up: { Votable: [ 1, 2 ] }
    # * as a Hash of +votable_gid+ to an array of GlobalID parameters.
    #
    # Some verification is performed to ensure that a single votable is not
    # represented in more than one collection. The votes are recorded as
    # follows:
    #
    # 1.  Remove the ballots against the votables in +remove+;
    # 2.  For votables in +down+:
    #     1.  Update existing ballots as down-votes;
    #     2.  Insert new down-vote ballots.
    # 3.  For votables in +up+:
    #     1.  Update existing ballots as up-votes;
    #     2.  Insert new up-vote ballots.
    #
    # The return value is a hash with the following structure:
    #
    #     {
    #       success: true, # or false if not successful
    #       exception: nil, # or an exception describing the failure
    #       up: 3, # the number of ballots added as or changed to up votes
    #       down: 3, # the number of ballots added as or changed to down votes
    #       remove: 0, # the number of ballots removed
    #     }
    #
    # The values of +up+, +down+, and +remove+ will be +nil+ if the transaction
    # was not successful.
    def cast_ballot_for_batch(up: [], down: [], remove: [], weight: 1, scope: nil)
    end

    ##
    # Records a positive vote by this Voter on the provided +votable+ with
    # options provided in +kwargs+. Any value passed to the +vote+ keyword
    # argument will be ignored. See #cast_ballot_for for more details.
    def cast_up_ballot_for(votable = nil, kwargs = {})
      cast_ballot_for(votable, kwargs.merge(vote: true))
    end
    alias up_ballot_for cast_up_ballot_for

    ##
    # Records a negative vote by this Voter on the provided +votable+ with
    # options provided in +kwargs+. Any value passed to the +vote+ keyword
    # argument will be ignored. See #cast_ballot_for for more details.
    def cast_down_ballot_for(votable = nil, kwargs = {})
      cast_ballot_for(votable, kwargs.merge(vote: false))
    end
    alias down_ballot_for cast_down_ballot_for

    ##
    # :method: remove_ballot_for
    # :call-seq:
    #    remove_ballot_for(votable = nil, kwargs = {})
    #    remove_ballot_for(votable)
    #    remove_ballot_for(votable_id: id, votable_type: type)
    #    remove_ballot_for(votable_gid: gid)
    #    remove_ballot_for(votable, scope: scope)
    #
    # Remove any votes by this Voter for the provided +votable+. The +votable+
    # may be specified as its own parameter, or through the keyword arguments
    # +votable_id+, +votable_type+, +votable_gid+, or +votable+ (note that the
    # parameter +votable+ will override the keyword argument +votable+, if both
    # are provided).
    #
    # Only the +scope+ argument is available through +kwargs+:
    #
    # scope:: The scope of the vote to be recorded. Defaults to +nil+.
    #
    # Other arguments are ignored.
    #
    # \ActiveRecord:: There are no special notes for \ActiveRecord.
    # \Sequel:: GlobalID does not currently provide support for \Sequel, so
    #           there are many cases where attempting to use +votable_gid+ will
    #           fail.

    #-----
    # :section: Finding Votes
    #-----

    ##
    # :method: ballots_by
    #
    # The votes attached to this Votable.
    #
    # \ActiveRecord:: This is generated by the polymorphic association
    #                 <tt>has_many :ballots_by</tt>.
    # \Sequel:: This is generated by the polymorphic association
    #           <tt>one_to_many :ballots_by</tt>

    ##
    # :method: ballots_for_dataset
    #
    # The \Sequel association dataset for votes attached to this Voter.
    #
    # \ActiveRecord:: This does not exist for \ActiveRecord.
    # \Sequel:: This is generated by the polymorphic association
    #           <tt>one_to_many :ballots_for</tt>

    ##
    # Returns ballots by this Voter where the recorded vote is positive.
    #
    # \ActiveRecord:: There are no special notes for ActiveRecord.
    # \Sequel:: This method returns the _dataset_; if vote objects are desired,
    #           use <tt>up_ballots_by.all</tt>.
    def up_ballots_by(kwargs = {})
      find_ballots_by(vote: true, scope: kwargs[:scope])
    end

    ##
    # Returns ballots by this Voter where the recorded vote is negative.
    #
    # \ActiveRecord:: There are no special notes for ActiveRecord.
    # \Sequel:: This method returns the _dataset_; if vote objects are desired,
    #           use <tt>down_ballots_by.all</tt>.
    def down_ballots_by(kwargs = {})
      find_ballots_by(vote: false, scope: kwargs[:scope])
    end

    #-----
    # :section: Votable Inquiries
    #-----

    ##
    # :method: cast_ballot_for?
    # :call-seq:
    #    ballot_for?(votable = nil, kwargs = {})
    #    ballot_for?(votable)
    #    ballot_for?(votable_id: id, votable_type: type)
    #    ballot_for?(votable_gid: gid)
    #    ballot_for?(votable, scope: scope, vote: false, weight: true)
    #
    # Returns +true+ if this Voter has voted for the provided +votable+
    # matching the provided criteria. The +votable+ may be specified as its own
    # parameter, or through the keyword arguments +votable_id+, +votable_type+,
    # +votable_gid+, or +votable+ (note that the parameter +votable+ will
    # override the keyword argument +votable+, if both are provided).
    #
    # Additional named arguments may be provided through +kwargs+:
    #
    # scope:: The scope of the vote to be recorded. Defaults to +nil+.
    # vote:: The vote to be queried. If present, is parsed through
    #        Ballot::Words.truthy?.
    #
    # Other arguments are ignored.
    #
    # \ActiveRecord:: There are no special notes for ActiveRecord.
    # \Sequel:: GlobalID does not currently provide support for Sequel. The use
    #           of +votable_gid+ in this case will probably fail.
    #
    # <em>Also aliased as: #ballot_for?.</em>

    ##
    # :method: ballot_for?
    # :call-seq:
    #    ballot_for?(votable = nil, kwargs = {})
    #    ballot_for?(votable)
    #    ballot_for?(votable_id: id, votable_type: type)
    #    ballot_for?(votable_gid: gid)
    #    ballot_for?(votable, scope: scope, vote: false, weight: true)
    #
    # <em>Alias for: #cast_ballot_for?.</em>

    ##
    # Returns +true+ if this Voter has made positive votes for the provided
    # +votable+. Any value passed to the +vote+ keyword argument will be
    # ignored. See #cast_ballot_for? for more details.
    def cast_up_ballot_for?(votable = nil, kwargs = {})
      cast_ballot_for?(votable, kwargs.merge(vote: true))
    end
    alias up_ballot_for? cast_up_ballot_for?

    ##
    # Returns +true+ if this Voter has made negative votes for the provided
    # +votable+. Any value passed to the +vote+ keyword argument will be
    # ignored. See #cast_ballot_for? for more details.
    def cast_down_ballot_for?(votable = nil, kwargs = {})
      cast_ballot_for?(votable, kwargs.merge(vote: false))
    end
    alias down_ballot_for? cast_down_ballot_for?

    ##
    # :method: ballot_as_cast_for
    # :call-seq:
    #    ballot_as_cast_for(votable = nil, kwargs = {})
    #    ballot_as_cast_for(votable)
    #    ballot_as_cast_for(votable_id: id, votable_type: type)
    #    ballot_as_cast_for(votable_gid: gid)
    #    ballot_as_cast_for(votable, scope: scope, vote: false, weight: true)
    #
    # Returns the Ballot::Vote#vote value of the ballot cast by this Voter
    # against the provided +votable+. The +votable+ may be specified as its own
    # parameter, or through the keyword arguments +votable_id+, +votable_type+,
    # +votable_gid+, or +votable+ (note that the parameter +votable+ will
    # override the keyword argument +votable+, if both are provided).
    #
    # If this Voter has not cast a ballot against the +votable+, returns +nil+.
    #
    # Additional named arguments may be provided through +kwargs+:
    #
    # scope:: The scope of the vote to be query. Defaults to +nil+.
    # vote:: The vote to be queried. If present, is parsed through
    #        Ballot::Words.truthy?.
    #
    # Other arguments are ignored.
    #
    # \ActiveRecord:: There are no special notes for ActiveRecord.
    # \Sequel:: GlobalID does not currently provide support for Sequel. The use
    #           of +votable_gid+ in this case will probably fail.

    ##
    # :method: ballots_for_class(model_class, kwargs = {})
    #
    # Find ballots cast by this Voter matching the canonical name of the
    # +model_class+ as the type of Votable.
    #
    # Additional named arguments may be provided through +kwargs+:
    #
    # scope:: The scope of the vote to be recorded. Defaults to +nil+.
    # vote:: The vote to be queried. If present, is parsed through
    #        Ballot::Words.truthy?.
    #
    # Other arguments are ignored.

    ##
    # Find positive ballots cast by this Voter matching the canonical name of
    # the +model_class+ as the type of Votable. Any value passed to the +vote+
    # keyword argument will be ignored. See #ballots_for_class for more
    # details.
    def up_ballots_for_class(model_class, kwargs = {})
      ballots_for_class(model_class, kwargs.merge(vote: true))
    end

    ##
    # Find negative ballots cast by this Voter matching the canonical name of
    # the +model_class+ as the type of Votable. Any value passed to the +vote+
    # keyword argument will be ignored. See #ballots_for_class for more
    # details.
    def down_ballots_for_class(model_class, kwargs = {})
      ballots_for_class(model_class, kwargs.merge(vote: false))
    end

    ##
    # Returns the Votable objects that this Voter has voted on. Additional
    # query conditions may be specified in +conds+, or in the +block+ if
    # supported by the ORM. The Voter objects are eager loaded to minimize the
    # number of queries required to satisfy this request.
    #
    # \ActiveRecord:: Polymorphic eager loading is directly supported, using
    #                 <tt>ballots_for.includes(:votable)</tt>. Normal
    #                 +where+-clause conditions may be provided in +conds+.
    # \Sequel:: Polymorphic eager loading is not supported by \Sequel, but has
    #           been implemented in Ballot for this method. Normal
    #           +where+-clause conditions may be provided in +conds+ or in
    #           +block+ for \Sequel virtual row support.
    def ballot_votables(*conds, &block)
      __eager_ballot_votables(find_ballots_by(*conds, &block))
    end

    ##
    # Returns the Votable objects that this Voter has made positive votes on.
    # See #ballot_voters for how +conds+ and +block+ apply.
    def ballot_up_votables(*conds, &block)
      __eager_ballot_votables(
        find_ballots_by(*conds, &block).where(vote: true)
      )
    end

    ##
    # Returns the Votable objects that this Voter has made negative votes on.
    # See #ballot_voters for how +conds+ and +block+ apply.
    def ballot_down_votables(*conds, &block)
      __eager_ballot_votables(
        find_ballots_by(*conds, &block).where(vote: false)
      )
    end

    private

    def __ballot_voter_kwargs(votable, kwargs = {})
      if votable.kind_of?(Hash)
        kwargs.merge(votable)
      elsif votable.nil?
        kwargs
      else
        kwargs.merge(votable: votable)
      end
    end

    # Methods added to the Voter model class.
    module ClassMethods
      # The class is now a voter record.
      def ballot_voter?
        true
      end
    end
  end
end
