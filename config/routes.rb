Rails.application.routes.draw do
  root to: 'home#index'
  
  get 'settings', to: 'settings#edit', as: :edit_setting
  patch 'settings', to: 'settings#update'

  resources :orders
  resources :catalogs do
    collection do
      get :export
    end
  end
end
