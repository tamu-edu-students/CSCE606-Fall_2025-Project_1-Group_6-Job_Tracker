class CompaniesController < ApplicationController
  before_action :set_company, only: [ :show ]

  def index
    @companies = Company.all
  end

  def show
    @jobs = @company.jobs.includes(:user)
  end

  def new
    @company = Company.new
  end

  def create
    @company = Company.new(company_params)
    if @company.save
      redirect_to @company, notice: "Company was successfully created."
    else
      render :new
    end
  end

  private
    def set_company
      @company = Company.find(params[:id])
    end

    def company_params
      params.require(:company).permit(:name, :website)
    end
end
