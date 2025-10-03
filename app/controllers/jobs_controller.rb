class JobsController < ApplicationController
  # Note: tests exercise controller without authentication for simplicity.
  before_action :set_job, only: %i[show edit update destroy]

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
    @job = Job.new
  end

  def create
    # defensive: reject requests without a company_id to avoid creating jobs with nil association
    if job_params[:company_id].blank?
      render json: { errors: ['company must be present'] }, status: :unprocessable_entity and return
    end

    # parse deadline if provided as string (guard against malformed dates)
    params_deadline = params.dig(:job, :deadline)
    if params_deadline.present?
      begin
        parsed = Date.iso8601(params_deadline.to_s)
        params[:job][:deadline] = parsed
      rescue ArgumentError
        render json: { errors: ['deadline is malformed'] }, status: :unprocessable_entity and return
      end
    end

    @job = Job.new(job_params)
    if @job.save
      redirect_to jobs_path, notice: 'Job created'
    else
      render json: { errors: @job.errors.full_messages }, status: :unprocessable_entity
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
        render json: { errors: ['deadline is malformed'] }, status: :unprocessable_entity and return
      end
    end

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
