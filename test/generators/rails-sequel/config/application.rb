# frozen_string_literal: true
require File.expand_path('../boot', __FILE__)

require 'rails'
require 'active_model/railtie'

Bundler.require(*Rails.groups)

module RailsSequel
  class Application < Rails::Application
    config.eager_load = false
    config.sequel.schema_dump = true
  end
end
