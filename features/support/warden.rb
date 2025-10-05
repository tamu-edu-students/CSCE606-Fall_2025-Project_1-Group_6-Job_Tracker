# Enable Warden test helpers in Cucumber world so steps can call `login_as`
require 'warden'

World(Warden::Test::Helpers)

Before do
  Warden.test_mode!
end

After do
  Warden.test_reset!
end
