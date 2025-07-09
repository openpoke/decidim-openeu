# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

DECIDIM_VERSION = { github: "decidim/decidim", branch: "release/0.29-stable" }.freeze
gem "decidim", DECIDIM_VERSION
gem "decidim-decidim_awesome", github: "decidim-ice/decidim-module-decidim_awesome", branch: "main"
gem "decidim-term_customizer", github: "openpoke/decidim-module-term_customizer"

gem "bootsnap", "~> 1.3"
gem "health_check"
gem "puma", ">= 6.3.1"
gem "sentry-rails"
gem "sentry-ruby"
# because we override the gem, we require it here
gem "aws-sdk-s3"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  gem "brakeman", "~> 6.1"
  gem "decidim-dev", "0.29.4"
end

group :development do
  gem "letter_opener_web"
  gem "web-console", "~> 4.2"
end

group :production do
  gem "sidekiq"
  gem "sidekiq-cron"
end
