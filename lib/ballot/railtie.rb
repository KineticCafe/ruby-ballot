# frozen_string_literal: true

##
module Ballot
  # = Ballot Railtie
  class Railtie < ::Rails::Railtie # :nodoc:
    initializer 'ballot' do
      ActiveSupport.on_load(:active_record) do
        require 'ballot/active_record'
        Ballot::ActiveRecord.inject!
      end

      ActiveSupport.on_load(:action_controller) do
        require 'ballot/action_controller'
        include Ballot::ActionController
      end
    end
  end
end
