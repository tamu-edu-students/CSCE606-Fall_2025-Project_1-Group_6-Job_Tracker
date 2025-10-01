class JobsController < ApplicationController
  before_action :set_job, only: [:show, :edit, :update, :destroy]

  def index
    @jobs = current_user.jobs.includes(:company)
  end

  def search
    query = params[:q].to_s.strip.downcase
    @jobs = current_user.jobs.includes(:company)
    if query.present?
      @jobs = @jobs.where("LOWER(jobs.title) LIKE ? OR LOWER(companies.name) LIKE ?", "%#{query}%", "%#{query}%").references(:company)
    end
    respond_to do |format|
      format.js { render partial: 'jobs/table', locals: { jobs: @jobs } }
    end
  end

  def show
  end

  def new
    @job = current_user.jobs.build
  end

  def create
    @job = current_user.jobs.build(job_params)
    if @job.save
      redirect_to dashboard_path, notice: 'Job application was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @job.update(job_params)
      redirect_to dashboard_path, notice: 'Job application was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @job.destroy
    redirect_to dashboard_path, notice: 'Job application was successfully deleted.'
  end

  private
    def set_job
      @job = current_user.jobs.find(params[:id])
    end

    def job_params
      params.require(:job).permit(:title, :company_id, :link, :deadline, :notes, :status)
    end
end

class JobsController < ApplicationController
  def index
  end
end
