# frozen_string_literal: true

##
module Ballot
  # The namespace for Ballot generators for Rails.
  module Generators
    ##
    # :attr_reader:
    # The ORM to use when generating the migrations.
    def orm
      if defined?(::Rails::Generators.options)
        ::Rails::Generators.options[:rails][:orm]
      else
        @orm || :active_record
      end
    end

    ##
    # Set the ORM to use when generating the migrations. Ignored under Rails.
    attr_writer :orm

    # The source root for the generator templates.
    def source_root
      File.expand_path(
        File.join('..', 'ballot', generator_name, 'templates', orm.to_s),
        __FILE__
      )
    end

    # Indicates whether the ORM is supported by these generators.
    def orm_has_migration?
      %i(active_record sequel).include? orm
    end

    # The next migration number.
    def next_migration_number(_path)
      Time.now.utc.strftime('%Y%m%d%H%M%S')
    end
  end
end
