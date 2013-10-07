# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20131007091606) do

  create_table "resources", force: true do |t|
    t.string   "owner"
    t.string   "name"
    t.string   "description"
    t.string   "manufacturer"
    t.string   "model"
    t.integer  "privacy"
    t.string   "notes"
    t.date     "last_updated"
    t.date     "creation_date"
    t.integer  "update_freq"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

# Could not dump table "streams" because of following NoMethodError
#   undefined method `[]' for nil:NilClass

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_digest"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true

end
