class RemoveAttributesFromStreams < ActiveRecord::Migration
  def change
    remove_column :streams, :longitude
    remove_column :streams, :latitude
    remove_column :streams, :notes
    remove_column :streams, :state

    rename_column :streams, :deviation, :accuracy
    rename_column :streams, :bound_max, :max_val
    rename_column :streams, :bound_min, :min_val
    rename_column :streams, :ranking, :user_ranking
    rename_column :streams, :created_at, :creation_date
    rename_column :streams, :updated_at, :last_updated

    add_column :streams, :tags, :string
    add_column :streams, :history_size, :int8
    add_column :streams, :subscribers, :int8
    add_column :resources, :active, :boolean
  end
end
