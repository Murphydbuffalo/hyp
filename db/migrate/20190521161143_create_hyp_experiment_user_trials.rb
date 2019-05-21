class CreateHypExperimentUserTrials < ActiveRecord::Migration[5.2]
  def change
    create_table :hyp_experiment_user_trials do |t|
      t.belongs_to :hyp_experiment,  foreign_key: true, index: true
      t.belongs_to :hyp_alternative, foreign_key: true, index: true
      t.bigint     :user_id,         null: false
      t.boolean    :converted,       null: false, default: false

      t.timestamps
    end

    add_index :hyp_experiment_user_trials,
              %i[hyp_experiment_id user_id],
              unique: true,
              name: 'uniq_experiment_user_trials_idx'
  end
end
