class CreateHypAlternatives < ActiveRecord::Migration[5.2]
  def change
    create_table :hyp_alternatives do |t|
      t.string :name, null: false
      t.belongs_to :hyp_experiment, foreign_key: true, index: true

      t.timestamps
    end
  end
end
