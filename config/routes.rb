Myflix::Application.routes.draw do
  get 'ui(/:action)', controller: 'ui'
  get 'home', to: 'videos#index'

  resources :videos, except: [:destroy]
end
