Hyp::Engine.routes.draw do
  resources :experiment_user_trials, only: %i[create] do
    collection do
      patch :convert
    end
  end
  resources :experiments
  resource  :sample_size, only: %i[show]
end
