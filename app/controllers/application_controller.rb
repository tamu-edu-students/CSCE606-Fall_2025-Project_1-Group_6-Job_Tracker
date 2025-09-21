class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :full_name, :phone, :location, :linkedin_url, :resume_url, :role,
      :notification_pref, :profile_completed
    ])
    devise_parameter_sanitizer.permit(:account_update, keys: [
      :full_name, :phone, :location, :linkedin_url, :resume_url, :role,
      :notification_pref, :profile_completed
    ])
  end
end
