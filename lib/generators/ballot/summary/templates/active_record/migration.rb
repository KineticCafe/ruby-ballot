# frozen_string_literal: true

class BallotCacheFor<%= class_name %> < ActiveRecord::Migration
  def change
    change_table :'<%= plural_table_name %>' do |t|
      if t.respond_to?(:jsonb)
        t.jsonb :cached_ballot_summary, null: false, default: {}
      elsif t.respond_to?(:json)
        t.json :cached_ballot_summary, null: false, default: {}
      else
        t.text :cached_ballot_summary, null: false, default: '{}'
      end
    end
  end
end
