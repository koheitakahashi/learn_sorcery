Rails.application.routes.draw do
  root 'books#index'
  resources :users
  resources :books
  get 'login', to: 'user_sessions#new', as: :login
  post 'login', to: "user_sessions#create"
  post 'logout', to: 'user_sessions#destroy', as: :logout
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
end
