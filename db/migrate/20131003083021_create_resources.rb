class CreateResources < ActiveRecord::Migration
  def change
    create_table :resources do |t|
      t.string :owner
      t.string :name
      t.string :description
      t.string :manufacturer
      t.string :model
      t.integer :privacy
      t.string :notes
      t.date :last_updated
      t.date :creation_date
      t.integer :update_freq
      t.string :resource_type

      t.timestamps
    end
  end
end
