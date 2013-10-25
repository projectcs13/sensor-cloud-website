class DropResourcesTable < ActiveRecord::Migration
	def up
		drop_table :resources
	end

	  def down
			raise ActiveRecord::IrreversibleMigration
		end
end
