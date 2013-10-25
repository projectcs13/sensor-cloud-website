class AddAttributesToResources < ActiveRecord::Migration
  def change
    add_column :resources, :data_overview, :string
    add_column :resources, :serial_num, :string
    add_column :resources, :make, :string
    add_column :resources, :location, :string
    add_column :resources, :uri, :string
    add_column :resources, :data_format, :string
    add_column :resources, :mirror_proxy, :string

    change_column :resources, :privacy, :string
  end
end
