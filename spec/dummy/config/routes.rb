Rails.application.routes.draw do
  mount Hyp::Engine => '/hyp'
  root to: 'examples#index'
  resources :examples, only: [:index]
end
