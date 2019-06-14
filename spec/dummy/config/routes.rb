Rails.application.routes.draw do
  mount Hyp::Engine => '/hyp'
  root to: 'root#index'
end
