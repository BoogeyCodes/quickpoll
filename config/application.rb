require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"

Bundler.require(*Rails.groups)

module Quickpoll
  class Application < Rails::Application
    config.load_defaults 7.1

    # This is an API-only application: no views, cookies, sessions or asset pipeline.
    config.api_only = true
  end
end
