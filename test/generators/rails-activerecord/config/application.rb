# frozen_string_literal: true
require File.expand_path('../boot', __FILE__)

require 'rails'
require 'active_model/railtie'
require 'active_record/railtie'

Bundler.require(*Rails.groups)

module RailsActiverecord
  class Application < Rails::Application
    if Rails::VERSION::MAJOR < 5
      config.active_record.raise_in_transactional_callbacks = true
    end
    config.eager_load = false
  end
end
