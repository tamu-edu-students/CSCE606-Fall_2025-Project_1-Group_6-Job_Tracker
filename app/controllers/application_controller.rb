class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    # Permit only the necessary fields during sign up and account update
    permitted_keys = [ :full_name, :phone, :profile_photo ]

    devise_parameter_sanitizer.permit(:sign_up, keys: permitted_keys)
    devise_parameter_sanitizer.permit(:account_update, keys: permitted_keys)
  end

  def after_sign_in_path_for(resource)
    dashboard_path
  end
end
