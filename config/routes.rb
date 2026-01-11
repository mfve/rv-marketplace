Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  post "/authenticate/sign_up", to: "authenticate#sign_up"
  post "/authenticate/token", to: "authenticate#token"

  resources :listings, only: [ :index, :show, :create, :update, :destroy ]
  resources :bookings, only: [ :index, :create ] do
    member do
      post :confirm
      post :reject
    end
  end
end
