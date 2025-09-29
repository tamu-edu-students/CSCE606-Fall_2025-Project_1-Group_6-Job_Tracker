class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @jobs = current_user.jobs.includes(:company)
  end

  def personal_info
    @user = current_user
  end
  
end
