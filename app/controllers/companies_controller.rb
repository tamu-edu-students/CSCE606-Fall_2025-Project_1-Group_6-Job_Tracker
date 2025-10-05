class CompaniesController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @companies = Company.all
  end

  def show
    @company = Company.find(params[:id])
    @jobs = @company.jobs.where(user: current_user)
  end

  def new
    @company = Company.new
  end

  def create
    @company = Company.new(company_params)
    if @company.save
      # If the company was created from the jobs new flow, return to the
      # job creation page so the user can select the new company and finish.
      if params[:return_to] == 'jobs_new' || (request.referer || '').include?('/jobs/new')
        redirect_to new_job_path, notice: 'Company created successfully'
      else
        redirect_to companies_path, notice: 'Company created successfully'
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def company_params
    params.require(:company).permit(:name, :website)
  end
end
