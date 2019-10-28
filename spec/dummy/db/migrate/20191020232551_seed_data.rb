class SeedData < ActiveRecord::Migration[6.0]
  def change
    Idiot.create!({name: 'Dan', age: 1})

    Hyp::ExperimentRepo.create(
      name: 'Sign Up CTA Copy',
      control: 0.01,
      minimum_detectable_effect: 0.2
    )
  end
end
