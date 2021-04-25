Rails.application.routes.draw do
  root 'books#index'
  resources :users
  resources :books
  get 'login', to: 'user_sessions#new', as: :login
  post 'login', to: "user_sessions#create"
  post 'logout', to: 'user_sessions#destroy', as: :logout
end
