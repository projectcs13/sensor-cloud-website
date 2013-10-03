class CreateStreams < ActiveRecord::Migration
  def change
    create_table :streams do |t|
      t.string :description
      t.integer :user_id

      t.timestamps
    end
  end
end
