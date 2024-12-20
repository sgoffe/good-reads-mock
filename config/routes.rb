Rails.application.routes.draw do
  get "pages/home"
  devise_for :users, controllers: { registrations: "users/registrations" }

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  root 'pages#home' 

  # books/reviews routes
  resources :books do
    resources :reviews
    # resources :lists, only: [:index]

    collection do
      get 'search_google', to: 'books#search_google', as: 'search_google'
      post 'add_google_book', to: 'books#add_google_book', as: 'add_google_book'
    end

    member do
      get 'recommend', to: 'notifications#recommend', as: 'recommend'
      post 'create_recommendation', to: 'notifications#create_recommendation', as: 'create_recommendation'
      post 'add_google_book', to: 'books#add_google_book'
    end
  end

  # users routes
  resources :users do
    resources :reviews
    resources :notifications, only: [:index]
    resources :friendships, only: [:new, :create, :destroy]
    resources :lists
  end

  resources :reviews, only: [:index, :show, :edit, :destroy, :update]

  # Custom routes 
  get '/books/:id/recommend', to: 'notifications#recommend', as: 'book_recommendation'
  post '/books/:id/create_recommendation', to: 'notifications#create_recommendation', as: 'create_book_recommendation'
  get '/friendships/find', to: 'friendships#find', as: 'friendships_find'
  get '/profile', to: 'users#profile'
  post '/google_books/add', to: 'books#add_google_book', as: 'add_google_book'
  get '/google_books/:id', to: 'books#show_google', as: 'google_book'
  get '/users/:id/admin', to: 'users#admin', as: 'user_admin'
  get '/users/:id/admin/moderate', to: 'users#admin_moderate', as: 'user_admin_moderate'
  # get '/books/:id/reviews/:id', to: 'reviews#show'
  post '/add_favorite/:id', to: 'lists#add_favorite', as: 'add_favorite'
end
