# frozen_string_literal: true

##
module Ballot
  # Extensions to \ActiveRecord to support Ballot.
  module ActiveRecord
    # Class method extensions to \ActiveRecord to support Ballot.
    module ClassMethods
      # ActiveRecord classes are not votable by default.
      def ballot_votable?
        false
      end

      # ActiveRecord classes are not voters by default.
      def ballot_voter?
        false
      end

      # The primary macro for marking an ActiveRecord class as votable.
      def acts_as_ballot(*types)
        types.each do |type|
          case type.to_s
          when 'votable'
            require 'ballot/active_record/votable'
            next if self < Ballot::ActiveRecord::Votable
            include Ballot::ActiveRecord::Votable
          when 'voter'
            require 'ballot/active_record/voter'
            next if self < Ballot::ActiveRecord::Voter
            include Ballot::ActiveRecord::Voter
          end
        end
      end

      # A shorthand version of <tt>acts_as_ballot :votable</tt>.
      def acts_as_ballot_votable
        acts_as_ballot :votable
      end

      # A shorthand version of <tt>acts_as_ballot :voter</tt>.
      def acts_as_ballot_voter
        acts_as_ballot :voter
      end
    end

    # Delegate the question of #votable? to the class.
    def ballot_votable?
      self.class.ballot_votable?
    end

    # Delegate the question of #voter? to the class.
    def ballot_voter?
      self.class.ballot_voter?
    end

    class << self
      # Put Ballot into ActiveRecord::Base.
      def inject!
        ::ActiveRecord::Base.instance_eval do
          return if self < Ballot::ActiveRecord

          include ::Ballot::ActiveRecord
          extend ::Ballot::ActiveRecord::ClassMethods
        end
        require 'ballot/active_record/vote'
      end

      # Respond with the canonical name for this model. Will be the root class
      # if an STI model.
      def type_name(model)
        return model if model.kind_of?(String)
        model = model.class if model.kind_of?(::ActiveRecord::Base)
        model.base_class.name
      end

      # Return a valid Votable object from the provided item or +nil+.
      # Permitted values are a Votable, a hash with the key +:votable+, or a
      # hash with the keys +:votable_type+ and +:votable_id+.
      def votable_for(item)
        votable =
          if item.kind_of?(::Ballot::ActiveRecord::Votable)
            item
          elsif item.kind_of?(Hash)
            if item[:votable]
              item[:votable]
            elsif item[:votable_type] && item[:votable_id]
              __instance_of_model(item[:votable_type], item[:votable_id])
            elsif item[:votable_gid]
              fail 'GlobalID is not enabled.' unless defined?(::GlobalID)

              # This should actually be GlobalID::Sequel::Locator when I
              # get that ported.
              GlobalID::Locator.locate(item[:votable_gid])
            end
          end

        votable if votable && votable.kind_of?(::ActiveRecord::Base) &&
            votable.ballot_votable?
      end

      # Return the id and canonical votable type name for the item, using
      # #votable_for.
      def votable_id_and_type_name_for(item)
        __id_and_type_name(votable_for(item))
      end

      # Return a valid Voter object from the provided item or +nil+. Permitted
      # values are a Voter, a hash with the key +:voter+, or a hash with the
      # keys +:voter_type+ and +:voter_id+.
      def voter_for(item)
        voter =
          if item.kind_of?(::Ballot::ActiveRecord::Voter)
            item
          elsif item.kind_of?(Hash)
            if item[:voter]
              item[:voter]
            elsif item[:voter_type] && item[:voter_id]
              __instance_of_model(item[:voter_type], item[:voter_id])
            elsif item[:voter_gid]
              fail 'GlobalID is not enabled.' unless defined?(::GlobalID)

              # This should actually be GlobalID::Sequel::Locator when I
              # get that ported.
              GlobalID::Locator.locate(item[:voter_gid])
            end
          end

        voter if voter && voter.kind_of?(::ActiveRecord::Base) &&
            voter.ballot_voter?
      end

      # Return the id and canonical voter type name for the item, using
      # #voter_for.
      def voter_id_and_type_name_for(item)
        __id_and_type_name(voter_for(item))
      end

      private

      # Return the id and canonical type name for the item.
      def __id_and_type_name(item)
        [ item.id, type_name(item) ] if item
      end

      def __instance_of_model(model, id)
        model.constantize.find(id)
      rescue
        nil
      end
    end
  end
end
