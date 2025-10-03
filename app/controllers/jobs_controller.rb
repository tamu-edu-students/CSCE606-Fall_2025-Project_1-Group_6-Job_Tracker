class JobsController < ApplicationController
  # Require authentication and always scope job operations to the signed-in user.
  before_action :authenticate_user!
  before_action :set_job, only: %i[show edit update destroy]

  def index
    # Simple, user-scoped list for the /jobs page that matches the dashboard.
    @jobs = current_user.jobs.includes(:company).order(created_at: :desc)
  end


  def show
  end

  def new
    @job = current_user.jobs.new
  end

  def create
    # Build job associated with the signed-in user only.
    if params.dig(:job, :company_id).blank?
      @job = current_user.jobs.new(job_params)
      @job.errors.add(:company, 'must be present')
      render :new, status: :unprocessable_entity and return
    end

    # parse deadline if provided as string (guard against malformed dates)
    params_deadline = params.dig(:job, :deadline)
    if params_deadline.present?
      begin
        parsed = Date.iso8601(params_deadline.to_s)
        params[:job][:deadline] = parsed
      rescue ArgumentError
        @job = current_user.jobs.new(job_params)
        @job.errors.add(:deadline, 'is malformed')
        render :new, status: :unprocessable_entity and return
      end
    end

    @job = current_user.jobs.new(job_params)
    if @job.save
      redirect_to jobs_path, notice: 'Job created'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    # parse deadline similar to create
    params_deadline = params.dig(:job, :deadline)
    if params_deadline.present?
      begin
        parsed = Date.iso8601(params_deadline.to_s)
        params[:job][:deadline] = parsed
      rescue ArgumentError
        @job.errors.add(:deadline, 'is malformed')
        render :edit, status: :unprocessable_entity and return
      end
    end

    if @job.update(job_params)
      redirect_to jobs_path, notice: 'Job updated'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @job.destroy
    redirect_to jobs_path, notice: 'Job deleted'
  end

  private

  def set_job
    @job = current_user.jobs.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to jobs_path, alert: 'Job not found'
  end

  def job_params
    params.require(:job).permit(:title, :company_id, :link, :deadline, :notes, :status)
  end
end
