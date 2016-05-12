# frozen_string_literal: true

class Minitest::RailsGeneratorSpec < Minitest::HooksSpec
  register_spec_type(/RailsGenerator/, self)

  let(:app_path) { "test/generators/rails-#{orm_name}" }

  def around
    ENV['RAILS_VERSION'] = rails_version
    ENV['ORM_VERSION'] = orm_version
    gemfile = File.join(File.expand_path(app_path), 'Gemfile')

    Dir.chdir(app_path) do
      without_current_bundler do
        ENV['BUNDLE_GEMFILE'] = gemfile
        system! 'git clean -fdx .'
        system! 'gem install bundler'
        if ENV['TRAVIS']
          system! 'bundle --version'
          system! 'bundle install'
        end
        system! 'bundle exec rake db:create'
        system! 'bundle exec rails g model votable name'
        run_migrations!

        yield
      end
    end
  ensure
    ENV.delete('ORM_VERSION')
    ENV.delete('RAILS_VERSION')
    ENV.delete('BUNDLE_GEMFILE')
  end

  def without_current_bundler(&block)
    if defined?(::Bundler)
      Bundler.with_clean_env(&block)
    else
      yield
    end
  end

  def assert_subprocess_output(stdout = nil, stderr = nil)
    out, err = capture_subprocess_io { yield }

    err_msg = stderr.kind_of?(Regexp) ? :assert_match : :assert_equal if stderr
    out_msg = stdout.kind_of?(Regexp) ? :assert_match : :assert_equal if stdout

    y = send err_msg, stderr, err, 'In stderr' if err_msg
    x = send out_msg, stdout, out, 'In stdout' if out_msg

    (!stdout || x) && (!stderr || y)
  end

  def assert_contents(contents, filename)
    contents_msg = contents.kind_of?(Regexp) ? :assert_match : :assert_equal
    send contents_msg, contents, File.read(filename), 'In contents'
  end

  def run_migrations
    system 'bundle exec rake db:migrate'
  end

  def run_migrations!
    system! 'bundle exec rake db:migrate'
  end

  def system!(command)
    output = capture_subprocess_io { system command }
    fail output.join("\n") unless $?.success?
  end

  def rails_generate(*args)
    system "bundle exec rails g #{args.join(' ')}"
  end

  class << self
    def focus!
      @focussed = true
    end

    def focussed?
      !!@focussed
    end

    def test_ballot_install(generate: nil, migrate: nil, contents: nil)
      return unless ENV['CI'] || ENV['TEST_GENERATORS']

      fail 'Contents must be provided' unless contents

      focus if focussed?
      it 'installs the ballot_votes table' do
        assert_subprocess_output generate || '' do
          rails_generate 'ballot:install'
        end

        assert_subprocess_output migrate || '' do
          run_migrations
        end

        assert_contents contents,
          Dir['db/migrate/*_install_ballot_vote_migration.rb'].first
      end
    end

    def test_ballot_summary_votable(generate: nil, migrate: nil, contents: nil)
      return unless ENV['CI'] || ENV['TEST_GENERATORS']

      fail 'Contents must be provided' unless contents

      focus if focussed?
      it 'adds the summary column to the votable table' do
        assert_nil File.read('db/schema.rb').match(/cached_ballot_summary/)

        assert_subprocess_output generate || '' do
          rails_generate 'ballot:summary', 'votable'
        end

        assert_subprocess_output migrate || '' do
          run_migrations
        end

        assert_contents contents,
          Dir['db/migrate/*_ballot_cache_for_votable.rb'].first
        assert_contents(/cached_ballot_summary/, 'db/schema.rb')
      end
    end
  end
end
