Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Frontend routes
  root "web/listings#index"
  get "/listings", to: "web/listings#index"
  get "/listings/new", to: "web/listings#new"
  get "/listings/:id/edit", to: "web/listings#edit"
  get "/listings/:id", to: "web/listings#show"
  get "/bookings", to: "web/bookings#index"
  get "/login", to: "web/sessions#new"
  get "/signup", to: "web/sessions#signup"

  # API routes (namespaced to avoid conflicts with frontend routes)
  namespace :api do
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
end
