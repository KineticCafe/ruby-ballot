# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in acts_as_votable.gemspec
gemspec

platforms :jruby do
  gem 'jdbc-sqlite3'
  gem 'activerecord-jdbcsqlite3-adapter'
end

platforms :mri do
  gem 'sqlite3'
end

gem 'sequel'

group :local_development, :test do
  gem 'appraisal', '~> 2.0'
  gem 'byebug', platforms: :mri
  gem 'pry'
end
