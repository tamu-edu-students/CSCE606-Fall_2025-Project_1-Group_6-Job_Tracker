class JobsController < ApplicationController
  # Note: tests exercise controller without authentication for simplicity.
  before_action :set_job, only: %i[show edit update destroy]

  def index
    @jobs = Job.all.includes(:company)
  end

  def show; end

  def new
    @job = Job.new
  end

  def create
    @job = Job.new(job_params)
    if @job.save
      redirect_to jobs_path, notice: 'Job created'
    else
      render json: { errors: @job.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @job.update(job_params)
      redirect_to jobs_path, notice: 'Job updated'
    else
      render json: { errors: @job.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @job.destroy
    redirect_to jobs_path, notice: 'Job deleted'
  end

  private

  def set_job
    @job = Job.find_by(id: params[:id])
    head :not_found unless @job
  end

  def job_params
    params.require(:job).permit(:title, :company_id, :link, :deadline, :notes, :status, :user_id)
  end
end
