# frozen_string_literal: true

require 'set'

##
module Ballot
  # Methods to determine whether the value of the vote word in question is
  # positive (#truthy?) or negative (#falsy?).
  module Words
    module_function

    # The list of 'words' recognized as falsy values for voting purposes. This
    # set can be added to for localization purposes. Any word *not* in this
    # list is considered truthy.
    FALSY = Set.new(
      [
        'down', 'downvote', 'dislike', 'disliked', 'negative', 'no', 'bad',
        'false', '0', '-1'
      ]
    )

    # Returns +true+ if the word supplied is not #falsy?.
    def truthy?(word)
      !falsy?(word)
    end

    # Returns +true+ if the word supplied is in the FALSY set.
    def falsy?(word)
      FALSY.include?(word.to_s.downcase)
    end
  end
end
