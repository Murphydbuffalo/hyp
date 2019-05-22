Rails.application.routes.draw do
  root to: 'root#index'
  mount Hyp::Engine => "/hyp"
end
