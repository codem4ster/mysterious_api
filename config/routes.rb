Rails.application.routes.draw do

  get 'user/index'

  get 'user/create'

  get 'user/new'

  get 'user/destroy'

  get 'user/show'

  get 'user/index'

  get 'user/create'

  get 'user/new'

  get 'user/destroy'

  get 'user/show'

  root 'application#index'
  resources :user
  resources :blog_post
  resources :comment
  mount_devise_token_auth_for 'User', at: 'auth'

end