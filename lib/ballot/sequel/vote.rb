# frozen_string_literal: true

##
module Ballot
  module Sequel
    # The Sequel implementation of Ballot::Vote.
    class Vote < ::Sequel::Model(:ballot_votes)
      dataset_module do
        subset(:up, vote: true) #:nodoc:
        subset(:down, vote: false) #:nodoc:

        def for_type(model_class) #:nodoc:
          where(votable_type: Ballot::Sequel.type_name(model_class))
        end

        def by_type(model_class) #:nodoc:
          where(voter_type: Ballot::Sequel.type_name(model_class))
        end
      end

      plugin :validation_helpers
      plugin :timestamps, update_on_create: true

      votable_setter = ->(votable_instance) {
        if votable_instance
          self[:votable_id] = votable_instance.pk
          self[:votable_type] = Ballot::Sequel.type_name(votable_instance)
        end
      }
      votable_dataset = -> {
        return if votable_type.nil? || votable_id.nil?
        klass = self.class.send(:constantize, votable_type)
        klass.where(klass.primary_key => votable_id)
      }
      votable_eager_loader = ->(eo) {
        id_map = {}
        eo[:rows].each do |model|
          model.associations[:votable] = nil
          next if model.votable_type.nil? || model.votable_id.nil?
          ((id_map[model.votable_type] ||= {})[model.votable_id] ||= []) << model
        end
        id_map.each do |klass_name, ids|
          klass = constantize(camelize(klass_name))
          klass.where(klass.primary_key => ids.keys).all do |related_obj|
            ids[related_obj.pk].each do |model|
              model.associations[:votable] = related_obj
            end
          end
        end
      }

      many_to_one :votable,
        reciprocal: :votes,
        reciprocal_type: :many_to_one,
        setter: votable_setter,
        dataset: votable_dataset,
        eager_loader: votable_eager_loader

      voter_setter = ->(voter_instance) {
        if voter_instance
          self[:voter_id] = voter_instance.pk
          self[:voter_type] = Ballot::Sequel.type_name(voter_instance)
        end
      }
      voter_dataset = -> {
        return if voter_type.nil? || voter_id.nil?
        klass = self.class.send(:constantize, voter_type)
        klass.where(klass.primary_key => voter_id)
      }
      voter_eager_loader = ->(eo) {
        id_map = {}
        eo[:rows].each do |model|
          model.associations[:voter] = nil
          next if model.voter_type.nil? || model.voter_id.nil?
          ((id_map[model.voter_type] ||= {})[model.voter_id] ||= []) << model
        end
        id_map.each do |klass_name, ids|
          klass = constantize(camelize(klass_name))
          klass.where(klass.primary_key => ids.keys).all do |related_obj|
            ids[related_obj.pk].each do |model|
              model.associations[:voter] = related_obj
            end
          end
        end
      }

      many_to_one :voter,
        reciprocal: :votes,
        reciprocal_type: :many_to_one,
        setter: voter_setter,
        dataset: voter_dataset,
        eager_loader: voter_eager_loader

      def validate # :nodoc:
        validates_presence %i(votable_id votable_type voter_id voter_type)
      end
    end
  end
end
