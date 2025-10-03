class JobsController < ApplicationController
  before_action :set_job, only: [:show, :edit, :update, :destroy]

  def index
    @jobs = current_user.jobs.includes(:company)

    sort = params[:sort]
    direction = params[:direction] == "desc" ? :desc : :asc

    case sort
    when "title"
      @jobs = @jobs.order(title: direction)
    when "company"
      @jobs = @jobs.joins(:company).order("companies.name #{direction}")
    when "status"
      @jobs = @jobs.order(status: direction)
    when "deadline"
      @jobs = @jobs.order(deadline: direction)
    end

    respond_to do |format|
      format.html
      format.turbo_stream
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
      redirect_to @job, notice: 'Job application was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @job.update(job_params)
      redirect_to @job, notice: 'Job application was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @job.destroy
    redirect_to jobs_url, notice: 'Job application was successfully deleted.'
  end

  private
    def set_job
      @job = current_user.jobs.find(params[:id])
    end

    def job_params
      params.require(:job).permit(:title, :company_id, :link, :deadline, :notes, :status)
    end
end
