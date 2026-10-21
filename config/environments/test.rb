Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = ENV["CI"].present?
  config.consider_all_requests_local = true
  config.action_dispatch.show_exceptions = :none
  config.active_support.deprecation = :stderr
  # The CI workflow prepares the test database explicitly, so skip the auto schema check.
  config.active_record.maintain_test_schema = false
  config.secret_key_base = "test-only-secret-key-base"
end
