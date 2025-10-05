module TestLoginHelpers
  # Provide a login_as helper for specs. Prefer Warden.test_mode sign-in
  # (fast). If Warden is not available, try Devise test helpers, otherwise
  # fall back to visiting the sign-in page (slower).
  def login_as(user, scope: :user)
    if defined?(Warden) && Warden.respond_to?(:test_mode)
      Warden.test_mode!
      Warden.set_user(user, scope: scope)
    elsif respond_to?(:sign_in)
      # Devise controller/test helper
      sign_in(user)
    else
      # As a last resort, perform a UI sign in (works with Capybara)
      visit new_user_session_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Log in'
    end
  end
end

RSpec.configure do |config|
  config.include TestLoginHelpers, type: :system
  config.include TestLoginHelpers, type: :request
end

# Make login_as available at the Kernel level as a safe fallback so any
# example or helper can call it regardless of include order.
module Kernel
  def login_as(user, scope: :user)
    if defined?(Warden) && Warden.respond_to?(:test_mode)
      Warden.test_mode!
      Warden.set_user(user, scope: scope)
    elsif respond_to?(:sign_in)
      sign_in(user)
    else
      visit new_user_session_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Log in'
    end
  end
end
