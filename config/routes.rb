Rails.application.routes.draw do
  root to: 'visitors#index'
  #root to: 'dashboard#index'
  resources :dashboard
end
