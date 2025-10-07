class RemindersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_reminder, only: [ :update, :destroy ]

  # GET /reminders
  # Show all upcoming active reminders
  def index
    @reminders = current_user.reminders.upcoming
  end

  # GET /reminders/new
  def new
    @reminder = current_user.reminders.new(job_id: params[:job_id])
  end

  # POST /reminders
  def create
    job = current_user.jobs.find(reminder_params[:job_id])
    @reminder = current_user.reminders.new(reminder_params.merge(job: job))

    if @reminder.save
      redirect_to reminders_path, notice: "Reminder created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PUT /reminders/:id
  # Used for enabling/disabling or updating reminder_time
  def update
    if @reminder.update(reminder_params)
      redirect_to reminders_path, notice: "Reminder updated successfully."
    else
      redirect_to reminders_path, alert: @reminder.errors.full_messages.to_sentence
    end
  end

  # DELETE /reminders/:id
  def destroy
    @reminder.destroy
    redirect_to reminders_path, notice: "Reminder deleted."
  end

  private

  def set_reminder
    @reminder = current_user.reminders.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to reminders_path, alert: "Reminder not found"
  end

  def reminder_params
    params.require(:reminder).permit(:job_id, :reminder_type, :reminder_time, :disabled)
  end
end
