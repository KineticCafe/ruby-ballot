# -*- ruby -*-

require 'rubygems'
require 'hoe'
require 'rake/clean'

Hoe.plugin :doofus
Hoe.plugin :email unless ENV['CI'] || ENV['TRAVIS']
Hoe.plugin :gemspec2
Hoe.plugin :git
Hoe.plugin :minitest
Hoe.plugin :rubygems
Hoe.plugin :travis

spec = Hoe.spec 'sequel-voting' do
  developer('Austin Ziegler', 'aziegler@kineticcafe.com')

  self.history_file = 'History.md'
  self.readme_file = 'README.rdoc'

  license 'MIT'

  ruby20!

  extra_deps << ['sequel', '~> 4.0']
  extra_deps << ['sequel_polymorphic', '~> 0.2']

  extra_dev_deps << ['sqlite3', '~>1.3']
  extra_dev_deps << ['rake', '>= 10.0']
  extra_dev_deps << ['rdoc', '~> 4.2']
  extra_dev_deps << ['hoe-doofus', '~> 1.0']
  extra_dev_deps << ['hoe-gemspec2', '~> 1.1']
  extra_dev_deps << ['hoe-git', '~> 1.5']
  extra_dev_deps << ['hoe-travis', '~> 1.2']
  extra_dev_deps << ['minitest', '~> 5.4']
  extra_dev_deps << ['minitest-autotest', '~> 1.0']
  extra_dev_deps << ['minitest-bisect', '~> 1.2']
  extra_dev_deps << ['minitest-bonus-assertions', '~> 2.0']
  extra_dev_deps << ['minitest-focus', '~> 1.1']
  extra_dev_deps << ['minitest-hooks', '~> 1.4']
  extra_dev_deps << ['minitest-moar', '~> 0.0']
  extra_dev_deps << ['minitest-pretty_diff', '~> 0.1']
  extra_dev_deps << ['simplecov', '~> 0.7']
end

module Hoe::Publish
  alias_method :original_make_rdoc_cmd, :make_rdoc_cmd

  def make_rdoc_cmd(*extra_args) # :nodoc:
    spec.extra_rdoc_files.reject! { |f| f == 'Manifest.txt' }
    original_make_rdoc_cmd(*extra_args)
  end
end

namespace :test do
  task :coverage do
    spec.test_prelude = %q(load ".simplecov-prelude.rb")

    Rake::Task['test'].execute
  end

  CLOBBER << 'coverage'
end

CLOBBER << 'tmp'

# vim: syntax=ruby
