class AddColumsinUserTable < ActiveRecord::Migration
  def change
  	add_column :users, :firstname, :string
  	add_column :users, :lastname, :string
    rename_column :users, :name, :username
  end
end
