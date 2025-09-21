class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def personal_info
    @user = current_user
  end
end
