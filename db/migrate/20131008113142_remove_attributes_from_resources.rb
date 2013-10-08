class RemoveAttributesFromResources < ActiveRecord::Migration
  def change
    remove_column :resources, :privacy
    remove_column :resources, :notes
    remove_column :resources, :last_updated
    remove_column :resources, :created_at
    remove_column :resources, :updated_at
    remove_column :resources, :data_format
  end
end
