class ChangeFollowedIdFormatForRelationships < ActiveRecord::Migration
  def change
    change_column :relationships, :followed_id, :string
  end
end
