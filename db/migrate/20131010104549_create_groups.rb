class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :owner
      t.string :name
      t.string :description
      t.string :tags
      t.string :input
      t.string :output
      t.boolean :private
      t.date :creation_date
      t.integer :subscribers
      t.integer :user_ranking

      t.timestamps
    end
  end
end
