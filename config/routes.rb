Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "users/registrations" }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  # config/routes.rb
  root 'search#start'

  get "dashboard", to: "dashboard#show"

  resources :movies, only: [:index, :show] do
    member do
      get :cast
      post :fetch_cast
    end

    collection do
      get :by_year
    end
  end
  resources :actors, only: [:show, :index]
  resources :favorite_actors, only: [:create, :destroy]

  # TV Shows
  resources :shows, only: [:index, :show] do
    member do
      get :cast
      post :fetch_cast
    end
  end

  # Search routes
  get 'watchlist', to: 'movies#watchlist'
  get 'watched', to: 'movies#watched'
  get 'liked', to: 'movies#liked'
  get 'pitch', to: 'movies#pitch'
  get 'actor_pitch', to: 'movies#actor_pitch'

  get 'search', to: 'search#index'
  get 'search/:id', to: 'search#show', as: 'search_show'

  # resources :movies already defined above with a member route

  resources :watchlist_items, only: [:create, :destroy]
  resources :viewings, only: [:create, :destroy]

  # Custom Lists
  resources :lists
  resources :list_items, only: [:create, :destroy]

  # Movie Likes (things people like about movies)
  resources :movie_likes, only: [:create, :destroy]
  resources :movie_like_votes, only: [:create, :destroy]

  resources :quizzes, only: [:new, :create, :show] do
    resources :quiz_questions, only: [:update], as: :questions
  end
  get 'leaderboard', to: 'leaderboard#show'

  namespace :watch do
    resource :quiz, only: [:show], controller: "quiz" do
      get :streaming
      get :length
      get :adventurousness
      get :category
      get :final
      get :completed
      post :complete
    end
  end

end
