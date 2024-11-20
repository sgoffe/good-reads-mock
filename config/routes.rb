Rails.application.routes.draw do
  devise_for :users, controllers: {registrations: "users/registrations"}
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  root "books#index"
  resources :books 
  resources :users do
    resources :notifications, only: [:index] 
    resources :friendships, only: [:new, :create, :destroy]
  end
  resources :reviews

  # custom routes 
  get '/books/:id/recommend', to: 'notifications#recommend', as: 'recommend_book'
  post '/books/:id/create_recommendation', to: 'notifications#create_recommendation', as: 'create_book_recommendation'
  get '/friendships/find', to: 'friendships#find', as: 'friendships_find'
end
