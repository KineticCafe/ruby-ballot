# frozen_string_literal: true

##
module Ballot
  # Extensions to Sequel::Model to support Ballot.
  module Sequel
    # Class method extensions to Sequel::Model to support Ballot.
    module ClassMethods
      # Sequel::Model classes are not votable by default.
      def ballot_votable?
        false
      end

      # Sequel::Model classes are not voters by default.
      def ballot_voter?
        false
      end

      # This macro makes migrating from ActiveRecord to Sequel (mostly)
      # painless. The preferred way is to simply enable the Sequel plug-in
      # directly:
      #
      #     class Voter
      #       plugin :ballot_voter
      #     end
      #
      #     class Votable
      #       plugin :ballot_votable
      #     end
      def acts_as_ballot(*types)
        types.each do |type|
          case type.to_s
          when 'votable'
            warn 'Prefer using the Sequel::Model plugin :ballot_votable directly.'
            plugin :ballot_votable
          when 'voter'
            warn 'Prefer using the Sequel::Model plugin :ballot_voter directly.'
            plugin :ballot_voter
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

    # Delegate the question of #ballot_votable? to the class.
    def ballot_votable?
      self.class.ballot_votable?
    end

    # Delegate the question of #ballot_voter? to the class.
    def ballot_voter?
      self.class.ballot_voter?
    end

    class << self
      # Respond with the canonical name for this model. This differs if the
      # model is STI-enabled.
      def type_name(model)
        return model if model.kind_of?(String)
        model = model.model if model.kind_of?(::Sequel::Model)
        if model.respond_to?(:sti_dataset)
          model.sti_dataset.model.name
        else
          model.name
        end
      end

      # Return a valid Votable object from the provided item or +nil+.
      # Permitted values are a Votable, a hash with the key +:votable+, or a
      # hash with the keys +:votable_type+ and +:votable_id+.
      def votable_for(item)
        votable =
          if item.kind_of?(::Sequel::Plugins::BallotVotable::InstanceMethods)
            item
          elsif item.kind_of?(Hash)
            if item[:votable]
              item[:votable]
            elsif item[:votable_type] && item[:votable_id]
              __instance_of_model(item[:votable_type], item[:votable_id])
            elsif item[:votable_gid]
              fail 'GlobalID is not enabled.' unless defined?(::GlobalID)

              # NOTE: Until GlobalID has patches or a plug-in to work with
              # Sequel, this is more likely to fail than to succeed.
              GlobalID::Locator.locate(item[:votable_gid])
            end
          end

        votable if votable && votable.kind_of?(::Sequel::Model) &&
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
          if item.kind_of?(::Sequel::Plugins::BallotVoter::InstanceMethods)
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

        voter if voter && voter.kind_of?(::Sequel::Model) &&
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
        constantize(model)[id]
      rescue
        nil
      end

      def constantize(s)
        s = s.to_s
        return s.constantize if s.respond_to?(:constantize)
        unless (m = VALID_CONSTANT_NAME_REGEXP.match(s))
          fail NameError, "#{s.inspect} is not a valid constant name!"
        end
        Object.module_eval("::#{m[1]}", __FILE__, __LINE__)
      end

      VALID_CONSTANT_NAME_REGEXP = /\A(?:::)?([A-Z]\w*(?:::[A-Z]\w*)*)\z/ #:nodoc:
      private_constant :VALID_CONSTANT_NAME_REGEXP
    end
  end
end

unless Sequel::Model < Ballot::Sequel
  Sequel::Model.send(:include, Ballot::Sequel)
  Sequel::Model.extend Ballot::Sequel::ClassMethods
end
