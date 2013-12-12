class DropMultistreamsTable < ActiveRecord::Migration
  def up
    drop_table :multistreams
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
