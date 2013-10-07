class AddMissingAttributesFromStreamMapping < ActiveRecord::Migration
  def self.up
  	rename_column :streams, :notes, :tags
  	rename_column :streams, :deviation, :accuracy
  	rename_column :streams, :bound_max, :max_val
  	rename_column :streams, :bound_min, :min_val
  	rename_column :streams, :state, :active
  end
  def self.down
  	rename_column :streams, :tags, :notes
  	rename_column :streams, :accuracy, :deviation
  	rename_column :streams, :max_val, :bound_max
  	rename_column :streams, :min_val, :bound_min
  	rename_column :streams, :active, :state
  end
  def change
  	add_column :streams, :active, :boolean
  	add_column :streams, :user_ranking, :float
  	add_column :streams, :history_size, :long
  	add_column :streams, :subscribers, :long
  end
end
