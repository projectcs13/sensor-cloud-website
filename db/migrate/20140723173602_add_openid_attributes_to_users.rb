class AddOpenidAttributesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :access_token, :string
    add_column :users, :refresh_token, :string
    add_column :users, :image_url, :string
  end
end
