Rails.application.routes.draw do
  # Registration/Login Routes
  devise_for :users, :controllers => {:sessions => "sessions", :registrations => "registrations", :passwords => "passwords"}
  devise_scope :user do
    get 'mc_billing' => 'sessions'
  end
  root to: 'dashboard#index'
  # root to: "home#index1"
  #root to: 'dashboard#index1'
  resources :dashboard do
    get :deferred
  end

  namespace :admin do
    resources :users do
      get :user_report, :on => :collection
      get :become, :on => :member
    end
    resources :vendors, :only => [:index, :new, :create, :show, :edit, :update] do
      put :update_features, :on => :member
      put :update_settings, :on => :member
      resources :users do
        get :become, :on => :member
      end
    end
    resources :workbenchs do
      get :jobs, :on => :collection
      get :job_details, :on => :collection
      get :sessions, :on => :collection
    end
  end

  resources :users do
    get :become, :on => :member
  end

  resources :products , :only => [:index,  :show] do

  end

  resources :inventories , :only => [:index,  :show] do

  end
  resource :vendor, :only => [] do


    resources :sales, :only => [:index, :new, :create, :show, :edit, :update] do

    end
    resources :inventories
    resources :users
  end
end
