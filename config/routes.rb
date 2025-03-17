Rails.application.routes.draw do
  
  mount_devise_token_auth_for 'User', at: 'auth'

  # get "up" => "rails/health#show", as: :rails_health_check
  resources :tasks
  resources :todo_lists

  resources :todo_lists do
    resources :tasks

  end
end
