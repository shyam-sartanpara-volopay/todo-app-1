Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'
  resources :todo_lists do
    resources :todos, only: %i[index create]
  end

  resources :todos, only: %i[show update destroy]
end
