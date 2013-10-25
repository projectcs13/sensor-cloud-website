class DropStreamsTable < ActiveRecord::Migration
	def up
		drop_table :streams
	end

	def down
		raise ActiveRecord::IrreversibleMigration
	end
end
