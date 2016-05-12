# frozen_string_literal: true
# -*- ruby encoding: utf-8 -*-

gem 'minitest'
require 'minitest/autorun'
require 'minitest/focus'
require 'minitest/moar'
require 'minitest/bisect'
require 'minitest-bonus-assertions'
require 'minitest/hooks/default'

require 'pathname'

Dir["#{__dir__}/support/**/*.rb"].sort.each do |f| require_relative f end
