require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module App
  class Application < Rails::Application
    config.load_defaults 7.0
    config.api_only = true
    config.hosts << "buckets-flow-backend.onrender.com"
    config.time_zone = 'Asia/Tokyo'
    config.active_record.default_timezone = :local
  end
end
