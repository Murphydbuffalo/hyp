Hyp::Engine.routes.draw do
  resources :experiment_user_trials, only: %i[create update]
  resources :experiments
  resource  :sample_size, only: %i[show]
end
