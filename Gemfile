source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.1"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.6"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem "jsbundling-rails"
# Bundle and process CSS [https://github.com/rails/cssbundling-rails]
gem "cssbundling-rails"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use the database-backed adapters for Rails.cache and Active Job
gem "solid_cache"
gem "solid_queue"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# GOV.UK Notify
gem "mail-notify", "~> 2.0.0"

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

gem "mission_control-jobs", "~> 1.1"

gem "down", "~> 5.4"

gem "csv", "~> 3.3"

gem "geocoder", "~> 1.8"

gem "draper", "~> 4.0"

gem "pagy", "~> 9.4"

gem "httparty", "~> 0.23.2"

gem "stimulus-rails", "~> 1.3"

gem "ostruct", "~> 0.6.1"

gem "strong_migrations"

# Markdown
gem "govuk_markdown"
gem "redcarpet", "~> 3.6"

# DfE Sign-in
gem "omniauth"
gem "omniauth_openid_connect"
gem "omniauth-rails_csrf_protection"

# Store user sessions in the database
gem "activerecord-session_store"

# User-Resource Permissions and Scoping
gem "pundit"

gem "okcomputer", "~> 1.19"

gem "dfe-analytics", github: "DFE-Digital/dfe-analytics", tag: "v1.15.12"

gem "google-cloud-bigquery", "1.61.1"
gem "google-apis-bigquery_v2", "0.95.0"
gem "json", "2.18.0"
gem "net-http", "0.6.0"
gem "uri", "1.1.1"

gem "sentry-ruby"
gem "sentry-rails"

group :development, :staging, :test, :review, :az_development do
  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false
  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false
end

group :development, :review, :staging, :test, :az_development do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
end

group :development do
  gem "rladr"
  gem "solargraph", require: false
  gem "solargraph-rails", require: false
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
  gem "rails-controller-testing"
  gem "shoulda-matchers"
  gem "webmock", "~> 3.26"
  gem "timecop", "~> 0.9.10"
  gem "undercover"
  gem "simplecov", require: false
  gem "simplecov-lcov", require: false
  gem "climate_control"
end

gem "govuk-components"
gem "govuk_design_system_formbuilder"

group :test, :development do
  gem "dotenv-rails", "~> 3.1"
  gem "erb_lint", require: false
  gem "factory_bot_rails"
  gem "rspec"
  gem "rspec-rails"
  gem "capybara-screenshot", "~> 1.0"
end

group :development, :review, :production, :staging, :az_development do
  gem "amazing_print"
  gem "rails_semantic_logger"
end
