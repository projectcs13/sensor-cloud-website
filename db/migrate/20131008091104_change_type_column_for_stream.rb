class ChangeTypeColumnForStream < ActiveRecord::Migration
  def change
  	rename_column :streams, :type, :stream_type
  end
end
