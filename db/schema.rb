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

ActiveRecord::Schema.define(version: 20131008114739) do

  create_table "resources", force: true do |t|
    t.string  "owner"
    t.string  "name"
    t.string  "description"
    t.string  "manufacturer"
    t.string  "model"
    t.date    "creation_date"
    t.integer "polling_freq"
    t.string  "type"
    t.string  "data_overview"
    t.string  "serial_num"
    t.string  "make"
    t.string  "location"
    t.string  "uri"
    t.boolean "mirror_proxy"
    t.string  "tags"
    t.boolean "active"
  end

  create_table "streams", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "private"
    t.float    "accuracy"
    t.string   "type"
    t.string   "unit"
    t.float    "max_val"
    t.float    "min_val"
    t.integer  "active"
    t.integer  "user_ranking"
    t.datetime "creation_date"
    t.datetime "last_updated"
    t.integer  "resource_id"
    t.integer  "user_id"
    t.string   "tags"
    t.integer  "history_size"
    t.integer  "subscribers"
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_digest"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true

end
