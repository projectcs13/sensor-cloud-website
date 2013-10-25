class ChangeDatatypeForPrivate < ActiveRecord::Migration
	def self.up
		change_table :streams do |t|
		t.change :private, :string
		end
	end
	def self.down
		change_table :streams do |t|
		t.change :private, :string
		end
	end
end
