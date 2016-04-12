# frozen_string_literal: true

module Sequel
  module Voting
    VERSION = '1.0' #:nodoc:

    unless Sequel::Model.respond_to?(:votable?)
      Sequel::Model.instance_eval do
        # Sequel::Model classes are not votable by default.
        def votable?
          false
        end

        # Sequel::Model classes are not voters by default.
        def voter?
          false
        end
      end

      Sequel::Model.class_eval do
        # Delegate the question of #votable? to the class.
        def votable?
          self.class.votable?
        end

        # Delegate the question of #voter? to the class.
        def voter?
          self.class.voter?
        end
      end
    end

    class << self
      # Respond with the canonical name for this model. This differs if the
      # model is STI-enabled.
      def type_name(model)
        model = model.model if model.kind_of?(Sequel::Model)
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
        votable = if item.kind_of?(Sequel::Plugins::Votable::InstanceMethods)
                    item
                  elsif item.kind_of?(Hash)
                    if item[:votable]
                      item[:votable]
                    elsif item[:votable_type] && item[:votable_id]
                      __instance_of_model(item[:votable_type], item[:votable_id])
                    end
                  end
        votable if votable && votable.kind_of?(Sequel::Model) && votable.votable?
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
        voter = if item.kind_of?(Sequel::Plugins::Voter::InstanceMethods)
                  item
                elsif item.kind_of?(Hash)
                  if item[:voter]
                    item[:voter]
                  elsif item[:voter_type] && item[:voter_id]
                    __instance_of_model(item[:voter_type], item[:voter_id])
                  end
                end

        voter if voter && voter.kind_of?(Sequel::Model) && voter.voter?
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

      VALID_CONSTANT_NAME_REGEXP = /\A(?:::)?([A-Z]\w*(?:::[A-Z]\w*)*)\z/
      private_constant :VALID_CONSTANT_NAME_REGEXP
    end

    module Words
      module_function

      ThatMean = {
        true => [
          'up', 'upvote', 'like', 'liked', 'positive', 'yes', 'good', 'true',
          1, true
        ].freeze,
        false => [
          'down', 'downvote', 'dislike', 'disliked', 'negative', 'no', 'bad',
          'false', 0, false
        ].freeze
      }.freeze

      def that_mean_true
        ThatMean[true]
      end

      def that_mean_false
        ThatMean[false]
      end

      def true?(word)
        !false?(word)
      end

      def false?(word)
        that_mean_false.include?(word)
      end
    end

    class Vote < Sequel::Model(:votes)
      dataset_module do
        subset(:up, vote_flag: true)
        subset(:down, vote_flag: false)

        def for_type(klass)
          where(votable_type: klass)
        end

        def by_type(klass)
          where(voter_type: klass)
        end
      end

      plugin :validation_helpers
      plugin :polymorphic
      plugin :timestamps, update_on_create: true

      many_to_one :votable, polymorphic: true
      many_to_one :voter, polymorphic: true

      def validate
        validates_presence [ :votable_id, :votable_type, :voter_id, :voter_type ]
      end
    end
  end

=begin
  module Plugins
    module Polymorphic
      def self.apply(model, options = {})
      end

      module InstanceMethods

      end

      module ClassMethods

        # Creates a many-to-one relationship.
        # Example: Comment.many_to_one :commentable, polymorphic: true
        def many_to_one(*args, &block)
          able, options = *args
          options ||= {}

          if options[:polymorphic]
            model = underscore(self.to_s)
            plural_model = pluralize(model)

            associate(:many_to_one, able,
              reciprocal: plural_model.to_sym,
              reciprocal_type: :many_to_one,
              setter: (proc do |able_instance|
                self[:"#{able}_id"]   = (able_instance.pk if able_instance)
                self[:"#{able}_type"] = (able_instance.class.name if able_instance)
              end),
              dataset: (proc do
                able_type = send(:"#{able}_type")
                able_id = send(:"#{able}_id")
                return if able_type.nil? || able_id.nil?
                klass = self.class.send(:constantize, able_type)
                klass.where(klass.primary_key => able_id)
              end),
              eager_loader: (proc do |eo|
                id_map = {}
                eo[:rows].each do |model|
                  model_able_type = model.send(:"#{able}_type")
                  model_able_id = model.send(:"#{able}_id")
                  model.associations[able] = nil
                  ((id_map[model_able_type] ||= {})[model_able_id] ||= []) << model if !model_able_type.nil? && !model_able_id.nil?
                end
                id_map.each do |klass_name, id_map|
                  klass = constantize(camelize(klass_name))
                  klass.where(klass.primary_key=>id_map.keys).all do |related_obj|
                    id_map[related_obj.pk].each do |model|
                      model.associations[able] = related_obj
                    end
                  end
                end
              end)
            )

          else
            associate(:many_to_one, *args, &block)
          end
        end

        alias :belongs_to :many_to_one


        # Creates a one-to-many relationship.
        # Note: Removing/clearing nullifies the *able fields in the related objects.
        # Example: Post.one_to_many :awesome_comments, as: :commentable
        def one_to_many(*args, &block)
          collection_name, options = *args
          options ||= {}

          if able = options[:as]
            able_id           = :"#{able}_id"
            able_type         = :"#{able}_type"
            many_dataset_name = :"#{collection_name}_dataset"

            associate(:one_to_many, collection_name,
              key: able_id,
              reciprocal: able,
              reciprocal_type: :one_to_many,
              conditions: {able_type => self.to_s},
              adder: proc { |many_of_instance| many_of_instance.update(able_id => pk, able_type => self.class.to_s) },
              remover: proc { |many_of_instance| many_of_instance.update(able_id => nil, able_type => nil) },
              clearer: proc { send(many_dataset_name).update(able_id => nil, able_type => nil) }
            )

          else
            associate(:one_to_many, *args, &block)
          end
        end

        alias :has_many :one_to_many


        # Creates a many-to-many relationship.
        # Note: Removing/clearing the collection deletes the instances in the through relationship (as opposed to nullifying the *able fields as in the one-to-many).
        # Example: Post.many_to_many :tags, through: :taggings, as: :taggable
        def many_to_many(*args, &block)
          collection_name, options = *args
          options ||= {}

          if through = (options[:through] || options[:join_table]) and able = options[:as]
            able_id                = :"#{able}_id"
            able_type              = :"#{able}_type"
            collection_singular    = singularize(collection_name.to_s).to_sym
            collection_singular_id = :"#{collection_singular}_id"
            through_klass          = constantize(singularize(camelize(through.to_s)))

            associate(:many_to_many, collection_name,
              left_key: able_id,
              join_table: through,
              conditions: {able_type => self.to_s},
              adder: proc { |many_of_instance| through_klass.create(collection_singular_id => many_of_instance.pk, able_id => pk, able_type => self.class.to_s) },
              remover: proc { |many_of_instance| through_klass.where(collection_singular_id => many_of_instance.pk, able_id => pk, able_type => self.class.to_s).delete },
              clearer: proc { through_klass.where(able_id => pk, able_type => self.class.to_s).delete }
            )

          else
            associate(:many_to_many, *args, &block)
          end
        end
      end # ClassMethods
    end # Polymorphic
  end # Plugins
=end
end