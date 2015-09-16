Rails.application.routes.draw do
  root to: 'home#index'
  
  get 'settings', to: 'settings#edit', as: :edit_setting
  patch 'settings', to: 'settings#update'

  resources :orders do
    collection do
      get :pull
    end
  end
  resources :catalogs do
    collection do
      get :export
    end
  end

  resources :contacts do
    collection do
      get :import_all
      get :export
    end
  end
end
