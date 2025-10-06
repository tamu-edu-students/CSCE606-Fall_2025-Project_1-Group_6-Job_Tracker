require 'cucumber/rails'
require 'simplecov'
SimpleCov.start

# Previous content of test helper now starts here
ActionController::Base.allow_rescue = false

begin
  DatabaseCleaner.strategy = :transaction
rescue NameError
  raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
end

Cucumber::Rails::Database.javascript_strategy = :truncation

# ✅ Include Warden helpers for Devise login
World(Warden::Test::Helpers)   # ← this is the key difference
Warden.test_mode!

After do
  Warden.test_reset!           # ← resets login state between scenarios
end

# ✅ Default Capybara driver
Capybara.default_driver = :rack_test

# Optional: use headless Chrome for JS/Turbo scenarios
# Capybara.javascript_driver = :selenium_chrome_headless
