# frozen_string_literal: true

#--
# This file exists for documentation purposes only. Ballot::Vote is an optional
# constant, and may be one of these values:
#
# *  Ballot::Sequel::Vote (when using *only* Sequel in an application);
# *  Ballot::ActiveRecord::Vote (when using *only* ActiveRecord in an application)
#++
unless defined?(Ballot::Sequel::Vote) || defined?(Ballot::ActiveRecord::Vote)
  fail 'ballot/vote cannot be required directly'
end

##
module Ballot
  # A Vote represents the votes stored in the +ballot_votes+ table, holding
  # votes for Votable objects by Voter objects.
  #
  # \ActiveRecord:: This is implemented as the Ballot::ActiveRecord::Vote
  #                 class.
  # \Sequel:: This is implemented as the Ballot::Sequel::Vote class.
  #
  #
  # NOTE:: Ballot::Vote is implemented as a method returning the primary
  #        implementation of the vote class. If _only_ Ballot::Sequel::Vote is
  #        defined, it will be returned. If _only_ Ballot::ActiveRecord::Vote
  #        is defined, it will be returned. If _both_ are defined, +nil+ will
  #        be returned.
  class Vote
    #-----
    # :section: Scope / Dataset Methods
    #-----

    ##
    # Returns all positive votes.
    #
    # \ActiveRecord:: This is a scope.
    # \Sequel:: This is a dataset module subset.
    def self.up; end

    ##
    # Returns all negative votes.
    #
    # \ActiveRecord:: This is a scope.
    # \Sequel:: This is a dataset module subset.
    def self.down; end

    ##
    # Returns all votes for Votable objects of the provided +model_class+. The
    # +model_class+ is resolved to the canonical name for the model, which
    # differs if the model is STI-enabled.
    #
    # \ActiveRecord:: This is a scope.
    # \Sequel:: This is a dataset module method.
    def self.for_type(model_class); end

    ##
    # Returns all votes for Voter objects of the provided +model_class+. The
    # +model_class+ is resolved to the canonical name for the model, which
    # differs if the model is STI-enabled.
    #
    # \ActiveRecord:: This is a scope.
    # \Sequel:: This is a dataset module method.
    def self.by_type(model_class); end

    #-----
    # :section:
    #-----

    ##
    # :attr_accessor: voter_id
    # The id of the Voter record for this Vote.

    ##
    # :attr_accessor: voter_type
    # The canonical model name for the Voter record for this Vote.

    ##
    # :attr_accessor: votable_id
    # The id of the Votable record for this Vote.

    ##
    # :attr_accessor: votable_type
    # The canonical model name for the Votable record for this Vote.

    ##
    # :attr_accessor: vote
    # The state of the Vote; +true+ if a positive vote, +false+ if a negative
    # vote.

    ##
    # :attr_accessor: scope
    # The optional scope for this Vote.

    ##
    # :attr_accessor: weight
    # The optional weight for this Vote. If missing, defaults to 1, but may be
    # any integer value.

    ##
    # :attr_reader: created_at
    # When this Vote record was created.

    ##
    # :attr_reader: updated_at
    # When this Vote record was last updated.

    ##
    # :attr_accessor: voter
    # The associated Voter for this Vote. Determined from #voter_id and
    # #voter_type.

    ##
    # :attr_accessor: votable
    # The associated Votable for this Vote. Determined from #votable_id and
    # #votable_type.
  end
  remove_const :Vote

  #--
  def self.Vote # :nodoc:
    if defined?(Ballot::Sequel::Vote) && !defined?(Ballot::ActiveRecord::Vote)
      Ballot::Sequel::Vote
    elsif defined?(Ballot::ActiveRecord::Vote)
      Ballot::ActiveRecord::Vote
    end
  end
  #++
end
