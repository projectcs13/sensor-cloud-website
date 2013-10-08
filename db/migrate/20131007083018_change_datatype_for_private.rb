class ChangeDatatypeForPrivate < ActiveRecord::Migration
	def self.up
		change_table :streams do |t|
		t.change :private, :boolean
		end
	end
	def self.down
		change_table :streams do |t|
		t.change :private, :boolean
		end
	end
end