class JobsController < ApplicationController
  # Require authentication and always scope job operations to the signed-in user.
  before_action :authenticate_user!
  before_action :set_job, only: %i[show edit update destroy]

  def index
    # Restore full behavior: start with the user's jobs, allow optional
    # sorting by column/direction, and support Turbo stream responses.
    @jobs = current_user.jobs.includes(:company)

    # block to filter jobs by status
    if params[:status].present? && params[:status] != 'all'
      @jobs = @jobs.where(status: params[:status])
    end

    # Server-side search fallback for non-JS clients: filter by q param
    if params[:q].present?
      q = "%#{params[:q].to_s.downcase}%"
      # use left_joins so jobs without a company are included
      @jobs = @jobs.left_joins(:company).where("LOWER(jobs.title) LIKE :q OR LOWER(companies.name) LIKE :q", q: q)
    end

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
  @job = current_user.jobs.new
  @companies = Company.all
end

  def create
    # Build job associated with the signed-in user only.
    if params.dig(:job, :company_id).blank?
      @job = current_user.jobs.new(job_params)
      @job.errors.add(:company, "must be present")
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
        @job.errors.add(:deadline, "is malformed")
        render :new, status: :unprocessable_entity and return
      end
    end

    @job = current_user.jobs.new(job_params)
    if @job.save
      # After creating a job, take the user to their dashboard so they see the
      # newly created entry in context.
      redirect_to dashboard_path, notice: "Job created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  @job = current_user.jobs.find(params[:id])
  @companies = Company.all
end


  def update
    # parse deadline similar to create
    params_deadline = params.dig(:job, :deadline)
    if params_deadline.present?
      begin
        parsed = Date.iso8601(params_deadline.to_s)
        params[:job][:deadline] = parsed
      rescue ArgumentError
        @job.errors.add(:deadline, "is malformed")
        render :edit, status: :unprocessable_entity and return
      end
    end

    if @job.update(job_params)
      # If the edit started from the dashboard, send the user back there so
      # they see the updated entry in the table. Fall back to jobs_path.
      if params[:from] == "dashboard" || (request.referer || "").include?("/dashboard")
        redirect_to dashboard_path, notice: "Job updated"
      else
        redirect_to jobs_path, notice: "Job updated"
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @job.destroy
    # If the delete was triggered from the dashboard, return there; otherwise go to jobs list.
    if params[:from] == "dashboard" || (request.referer || "").include?("/dashboard")
      redirect_to dashboard_path, notice: "Job deleted"
    else
      redirect_to jobs_path, notice: "Job deleted"
    end
  end

  def update_status
    @job = current_user.jobs.find(params[:id])
    if @job.update(status: params[:job][:status])
      redirect_to jobs_path, notice: "Status updated successfully."
    else
      redirect_to jobs_path, alert: "Failed to update status."
    end
  end


  private

  def set_job
    @job = current_user.jobs.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to jobs_path, alert: "Job not found"
  end

  def job_params
    params.require(:job).permit(:title, :company_id, :link, :deadline, :notes, :status)
  end
end
