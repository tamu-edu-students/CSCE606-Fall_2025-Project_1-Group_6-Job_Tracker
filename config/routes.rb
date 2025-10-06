Rails.application.routes.draw do
  devise_for :users

  root to: "landing#index"

  get "dashboard", to: "dashboard#index"
  get "personal_info", to: "dashboard#personal_info"
  get "up" => "rails/health#show", as: :rails_health_check
  get "my_jobs", to: "jobs#index", as: "my_jobs"
  get "home", to: "home#index"

  resources :jobs do
    member do
      patch :update_status
    end
  end

  resources :jobs
  resources :jobs, only: [ :index ]
  resources :companies, only: [ :index, :show, :new, :create ]
  resources :reminders, only: [ :index, :new, :create, :update, :destroy ]
end
