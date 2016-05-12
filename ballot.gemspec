# -*- encoding: utf-8 -*-
# stub: ballot 1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "ballot".freeze
  s.version = "1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Austin Ziegler".freeze]
  s.date = "2016-05-12"
  s.description = "Ballot provides a two-way polymorphic scoped voting mechanism for both\nActiveRecord (4 or later) and Sequel (4 or later).".freeze
  s.email = ["aziegler@kineticcafe.com".freeze]
  s.executables = ["ballot_generator".freeze]
  s.extra_rdoc_files = ["Contributing.md".freeze, "History.md".freeze, "Licence.md".freeze, "Manifest.txt".freeze, "README.rdoc".freeze]
  s.files = ["Contributing.md".freeze, "History.md".freeze, "Licence.md".freeze, "Manifest.txt".freeze, "README.rdoc".freeze, "Rakefile".freeze, "bin/ballot_generator".freeze, "lib/ballot.rb".freeze, "lib/ballot/action_controller.rb".freeze, "lib/ballot/active_record.rb".freeze, "lib/ballot/active_record/votable.rb".freeze, "lib/ballot/active_record/vote.rb".freeze, "lib/ballot/active_record/voter.rb".freeze, "lib/ballot/railtie.rb".freeze, "lib/ballot/sequel.rb".freeze, "lib/ballot/sequel/vote.rb".freeze, "lib/ballot/votable.rb".freeze, "lib/ballot/vote.rb".freeze, "lib/ballot/voter.rb".freeze, "lib/ballot/words.rb".freeze, "lib/generators/ballot.rb".freeze, "lib/generators/ballot/install/install_generator.rb".freeze, "lib/generators/ballot/install/templates/active_record/migration.rb".freeze, "lib/generators/ballot/install/templates/sequel/migration.rb".freeze, "lib/generators/ballot/standalone.rb".freeze, "lib/generators/ballot/standalone/support.rb".freeze, "lib/generators/ballot/summary/summary_generator.rb".freeze, "lib/generators/ballot/summary/templates/active_record/migration.rb".freeze, "lib/generators/ballot/summary/templates/sequel/migration.rb".freeze, "lib/sequel/plugins/ballot_votable.rb".freeze, "lib/sequel/plugins/ballot_voter.rb".freeze, "test/active_record/ballot_votable_test.rb".freeze, "test/active_record/ballot_voter_test.rb".freeze, "test/active_record/rails_generator_test.rb".freeze, "test/active_record/votable_voter_test.rb".freeze, "test/generators/rails-activerecord/Rakefile".freeze, "test/generators/rails-activerecord/app/.keep".freeze, "test/generators/rails-activerecord/bin/rails".freeze, "test/generators/rails-activerecord/config/application.rb".freeze, "test/generators/rails-activerecord/config/boot.rb".freeze, "test/generators/rails-activerecord/config/database.yml".freeze, "test/generators/rails-activerecord/config/environment.rb".freeze, "test/generators/rails-activerecord/config/routes.rb".freeze, "test/generators/rails-activerecord/config/secrets.yml".freeze, "test/generators/rails-activerecord/db/seeds.rb".freeze, "test/generators/rails-activerecord/log/.keep".freeze, "test/generators/rails-sequel/Rakefile".freeze, "test/generators/rails-sequel/app/.keep".freeze, "test/generators/rails-sequel/bin/rails".freeze, "test/generators/rails-sequel/config/application.rb".freeze, "test/generators/rails-sequel/config/boot.rb".freeze, "test/generators/rails-sequel/config/database.yml".freeze, "test/generators/rails-sequel/config/environment.rb".freeze, "test/generators/rails-sequel/config/routes.rb".freeze, "test/generators/rails-sequel/config/secrets.yml".freeze, "test/generators/rails-sequel/db/seeds.rb".freeze, "test/generators/rails-sequel/log/.keep".freeze, "test/minitest_config.rb".freeze, "test/sequel/ballot_votable_test.rb".freeze, "test/sequel/ballot_voter_test.rb".freeze, "test/sequel/rails_generator_test.rb".freeze, "test/sequel/votable_voter_test.rb".freeze, "test/sequel/vote_test.rb".freeze, "test/support/active_record_setup.rb".freeze, "test/support/generators_setup.rb".freeze, "test/support/sequel_setup.rb".freeze, "test/support/shared_examples/votable_examples.rb".freeze, "test/support/shared_examples/voter_examples.rb".freeze]
  s.homepage = "https://github.com/KineticCafe/ruby-ballot/".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--main".freeze, "README.rdoc".freeze]
  s.required_ruby_version = Gem::Requirement.new("~> 2.0".freeze)
  s.rubygems_version = "2.6.4".freeze
  s.summary = "Ballot provides a two-way polymorphic scoped voting mechanism for both ActiveRecord (4 or later) and Sequel (4 or later).".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<minitest>.freeze, ["~> 5.8"])
      s.add_development_dependency(%q<rdoc>.freeze, ["~> 4.0"])
      s.add_development_dependency(%q<rake>.freeze, [">= 10.0"])
      s.add_development_dependency(%q<hoe-doofus>.freeze, ["~> 1.0"])
      s.add_development_dependency(%q<hoe-gemspec2>.freeze, ["~> 1.1"])
      s.add_development_dependency(%q<hoe-git>.freeze, ["~> 1.5"])
      s.add_development_dependency(%q<hoe-travis>.freeze, ["~> 1.2"])
      s.add_development_dependency(%q<minitest-autotest>.freeze, ["~> 1.0"])
      s.add_development_dependency(%q<minitest-bisect>.freeze, ["~> 1.2"])
      s.add_development_dependency(%q<minitest-bonus-assertions>.freeze, ["~> 2.0"])
      s.add_development_dependency(%q<minitest-focus>.freeze, ["~> 1.1"])
      s.add_development_dependency(%q<minitest-hooks>.freeze, ["~> 1.4"])
      s.add_development_dependency(%q<minitest-moar>.freeze, ["~> 0.0"])
      s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.7"])
      s.add_development_dependency(%q<hoe>.freeze, ["~> 3.15"])
    else
      s.add_dependency(%q<minitest>.freeze, ["~> 5.8"])
      s.add_dependency(%q<rdoc>.freeze, ["~> 4.0"])
      s.add_dependency(%q<rake>.freeze, [">= 10.0"])
      s.add_dependency(%q<hoe-doofus>.freeze, ["~> 1.0"])
      s.add_dependency(%q<hoe-gemspec2>.freeze, ["~> 1.1"])
      s.add_dependency(%q<hoe-git>.freeze, ["~> 1.5"])
      s.add_dependency(%q<hoe-travis>.freeze, ["~> 1.2"])
      s.add_dependency(%q<minitest-autotest>.freeze, ["~> 1.0"])
      s.add_dependency(%q<minitest-bisect>.freeze, ["~> 1.2"])
      s.add_dependency(%q<minitest-bonus-assertions>.freeze, ["~> 2.0"])
      s.add_dependency(%q<minitest-focus>.freeze, ["~> 1.1"])
      s.add_dependency(%q<minitest-hooks>.freeze, ["~> 1.4"])
      s.add_dependency(%q<minitest-moar>.freeze, ["~> 0.0"])
      s.add_dependency(%q<simplecov>.freeze, ["~> 0.7"])
      s.add_dependency(%q<hoe>.freeze, ["~> 3.15"])
    end
  else
    s.add_dependency(%q<minitest>.freeze, ["~> 5.8"])
    s.add_dependency(%q<rdoc>.freeze, ["~> 4.0"])
    s.add_dependency(%q<rake>.freeze, [">= 10.0"])
    s.add_dependency(%q<hoe-doofus>.freeze, ["~> 1.0"])
    s.add_dependency(%q<hoe-gemspec2>.freeze, ["~> 1.1"])
    s.add_dependency(%q<hoe-git>.freeze, ["~> 1.5"])
    s.add_dependency(%q<hoe-travis>.freeze, ["~> 1.2"])
    s.add_dependency(%q<minitest-autotest>.freeze, ["~> 1.0"])
    s.add_dependency(%q<minitest-bisect>.freeze, ["~> 1.2"])
    s.add_dependency(%q<minitest-bonus-assertions>.freeze, ["~> 2.0"])
    s.add_dependency(%q<minitest-focus>.freeze, ["~> 1.1"])
    s.add_dependency(%q<minitest-hooks>.freeze, ["~> 1.4"])
    s.add_dependency(%q<minitest-moar>.freeze, ["~> 0.0"])
    s.add_dependency(%q<simplecov>.freeze, ["~> 0.7"])
    s.add_dependency(%q<hoe>.freeze, ["~> 3.15"])
  end
end
