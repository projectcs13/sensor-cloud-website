class AddMissingAttributesFromStreamMapping < ActiveRecord::Migration
  def change
  	add_column :streams, :active, :boolean
  	add_column :streams, :user_ranking, :float
  	add_column :streams, :history_size, :integer
  	add_column :streams, :subscribers, :integer
    remove_column :streams, :ranking
  	rename_column :streams, :notes, :tags
  	rename_column :streams, :deviation, :accuracy
  	rename_column :streams, :bound_max, :max_val
  	rename_column :streams, :bound_min, :min_val
  	#rename_column :streams, :state, :active
  end
end
