# This migration comes from hyp (originally 20190427221623)
class CreateHypExperiments < ActiveRecord::Migration[5.2]
  def change
    create_table :hyp_experiments do |t|
      t.string :name, null: false
      t.float :alpha, null: false, default: 0.05
      t.float :power, null: false, default: 0.80
      t.float :control, null: false
      t.float :minimum_detectable_effect, null: false

      t.timestamps
    end

    add_index :hyp_experiments, :name, :unique => true
  end
end
