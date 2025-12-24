Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  # config/routes.rb
  root 'movies#index'

  resources :movies, only: [:index, :show] do
    member do
      get :cast
      post :fetch_cast
    end
  end
  resources :actors, only: [:show, :index]
  resources :favorite_actors, only: [:create, :destroy]

  # Search routes
  get 'watchlist', to: 'movies#watchlist'
  get 'pitch', to: 'movies#pitch'
  get 'actor_pitch', to: 'movies#actor_pitch'

  get 'search', to: 'search#index'
  get 'search/:id', to: 'search#show', as: 'search_show'

  # resources :movies already defined above with a member route

  resources :watchlist_items, only: [:create, :destroy]
  resources :viewings, only: [:create]

end
