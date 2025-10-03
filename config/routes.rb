Rails.application.routes.draw do
  devise_for :users

  root to: "landing#index"

  get "dashboard", to: "dashboard#index"
  get "personal_info", to: "dashboard#personal_info"
<<<<<<< HEAD

  resources :jobs
  resources :companies, only: [:index, :show, :new, :create]

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
=======
  get "up" => "rails/health#show", as: :rails_health_check
  get 'my_jobs', to: 'jobs#index', as: 'my_jobs'

  resources :jobs
  resources :jobs, only: [:index]
  resources :companies, only: [:index, :show, :new, :create]
>>>>>>> main
end

