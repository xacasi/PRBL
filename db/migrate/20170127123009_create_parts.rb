class CreateParts < ActiveRecord::Migration[5.0]
  def change
    create_table :parts do |t|
      t.string :partname
      t.string :part_number
      t.string :unit
      t.references :bus_model, foreign_key: true
      t.integer :index_number
      t.float :price
      t.integer :lifespan

      t.timestamps
    end
  end
end
