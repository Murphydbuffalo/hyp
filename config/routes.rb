Hyp::Engine.routes.draw do
  resources :experiment_user_trials, only: %i[create update]
  resources :experiments
end
