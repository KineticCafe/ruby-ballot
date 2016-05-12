# frozen_string_literal: true

Sequel.migration do
  change do
    types = %i(jsonb json String)
    column_options = {
      null: false,
      default: '{}'
    }

    alter_table :'<%= plural_table_name %>' do
      begin
        type = types.shift
        add_column :cached_ballot_summary, type, column_options
      rescue
        types.empty? && raise || retry
      end
    end
  end
end
