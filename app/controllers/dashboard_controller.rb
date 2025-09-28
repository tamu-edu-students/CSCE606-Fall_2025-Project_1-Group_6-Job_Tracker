class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @jobs = Job.includes(:company).all
  end

  def personal_info
    @user = current_user
  end
  
end
