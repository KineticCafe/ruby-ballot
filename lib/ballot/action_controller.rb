# frozen_string_literal: true

##
module Ballot
  # Extensions to \ActionController to support the use of Ballot in a Rails
  # application.
  module ActionController
    # Provide a consistent way to extract ballot parameters from request
    # parameters. The +ballot+ defaults to <tt>params[:ballot]</tt>.
    #
    # It permits:
    #
    # *   Votables to be described by type and id (+:votable_type+,
    #     +:votable_id+), a GlobalID locator (+:votable_gid+), or an object
    #     (+:votable+).
    # *   Voters to be described by type and id (+:voter_type+, +:voter_id+), a
    #     GlobalID locator (+:voter_gid+), or an object (+:voter+).
    # *   The recorded vote (+:vote+, a word or value that means true or false,
    #     see Ballot::Words).
    # *   The scope for the vote (+:scope+).
    # *   The weight for the vote (+:weight+).
    def ballot_params(ballot = params[:ballot])
      ballot.permit(
        :votable_type, :votable_id, :votable_gid, :votable,
        :voter_type, :voter_id, :voter_gid, :voter,
        :vote,
        :scope,
        :weight
      )
    end
  end
end
