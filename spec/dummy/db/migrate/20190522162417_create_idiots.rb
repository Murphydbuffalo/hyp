class CreateIdiots < ActiveRecord::Migration[5.2]
  def change
    create_table :idiots do |t|
      t.string :name
      t.integer :age

      t.timestamps
    end
  end
end
