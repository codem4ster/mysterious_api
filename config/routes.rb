Rails.application.routes.draw do

  root 'application#index'
  resources :user
  resources :blog_post
  resources :comment
  mount_devise_token_auth_for 'User', at: 'auth'

end