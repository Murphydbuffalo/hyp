class CreateHypExperimentUserTrials < ActiveRecord::Migration[5.2]
  def change
    create_table :hyp_experiment_user_trials do |t|
      t.belongs_to :hyp_experiment,  foreign_key: true, index: true
      t.belongs_to :hyp_alternative, foreign_key: true, index: true
      t.boolean    :converted,       null: false,       default: false

      t.timestamps
    end

    add_column      :hyp_experiment_user_trials, Hyp.user_foreign_key_name, :bigint, index: true
    add_foreign_key :hyp_experiment_user_trials, Hyp.user_relation_name, column: Hyp.user_foreign_key_name

    add_index :hyp_experiment_user_trials,
              [:hyp_experiment_id, Hyp.user_foreign_key_name],
              unique: true,
              name: 'uniq_experiment_user_trials_idx'
  end
end
