class CreateStreams < ActiveRecord::Migration
  def change
    create_table :streams do |t|
      t.string :name
      t.text :description
      t.integer :private
      t.float :deviation
      t.float :longitude
      t.float :latitude
      t.string :type
      t.string :unit
      t.float :bound_max
      t.float :bound_min
      t.integer :state
      t.integer :ranking
      t.text :notes

      t.timestamps
    end
  end
end
