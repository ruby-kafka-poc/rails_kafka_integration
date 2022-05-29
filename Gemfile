# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'activesupport', '~> 7.0.2'
gem 'rake'
gem 'ruby-kafka'

group :development, :test do
  gem 'bullet'
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails'
end

group :development do
  gem 'rubocop'
  gem 'rubocop-performance'
  # gem 'rubocop-rake'
  # Error: RuboCop found unsupported Ruby version 2.5 in `TargetRubyVersion`
  # parameter (in vendor/bundle/ruby/3.1.0/gems/rubocop-rake-0.6.0/.rubocop.yml).
  # 2.5-compatible analysis was dropped after version 1.28.
  gem 'rubocop-rspec'
  gem 'spring'
end

group :test do
  gem 'rspec'
  # gem 'simplecov'
  gem 'simplecov-gem-profile'
end
