class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @jobs = current_user.jobs.includes(:company)
    if params[:q].present?
      q = "%#{params[:q].downcase}%"
      @jobs = @jobs.joins(:company).where("LOWER(jobs.title) LIKE :q OR LOWER(companies.name) LIKE :q", q: q)
    end
  end

  def personal_info
    @user = current_user
  end
end
