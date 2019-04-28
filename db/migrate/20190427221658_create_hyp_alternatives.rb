class CreateHypAlternatives < ActiveRecord::Migration[5.2]
  def change
    create_table :hyp_alternatives do |t|
      t.string :name, null: false
      t.integer :trials, null: false, default: 0
      t.integer :conversions, null: false, default: 0
      t.belongs_to :hyp_experiment, foreign_key: true

      t.timestamps
    end
  end
end
