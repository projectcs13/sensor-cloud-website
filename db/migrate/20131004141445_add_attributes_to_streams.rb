class AddAttributesToStreams < ActiveRecord::Migration
  def change
    add_column :streams, :resource_id, :integer
    add_column :streams, :user_id, :integer
  end
end
