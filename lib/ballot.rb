# frozen_string_literal: true

##
# Ballot provides a two-way polymorphic scoped voting mechanism for both
# ActiveRecord (4 or later) and Sequel (4 or later).
#
# -   Two-way polymorphic: any model can be a voter or a votable.
# -   Scoped: multiple votes can be recorded for a votable, under different
#     scopes.
#
# The API for Ballot is consistent across both supported ORMs.
module Ballot
  VERSION = '1.0' #:nodoc:
end

#:stopdoc:
require 'ballot/words'
require 'ballot/sequel' if defined?(::Sequel::Model)
if defined?(::Rails)
  require 'ballot/railtie'
elsif defined?(::ActiveRecord::Base)
  require 'ballot/active_record'
  Ballot::ActiveRecord.inject!
end
#:startdoc:
