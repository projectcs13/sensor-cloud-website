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

ActiveRecord::Schema.define(version: 20131014115546) do

  create_table "groups", force: true do |t|
    t.string   "owner"
    t.string   "name"
    t.string   "description"
    t.string   "tags"
    t.string   "input"
    t.string   "output"
    t.boolean  "private"
    t.date     "creation_date"
    t.integer  "subscribers"
    t.integer  "user_ranking"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "resources", force: true do |t|
    t.string  "owner"
    t.string  "name"
    t.string  "description"
    t.string  "manufacturer"
    t.string  "model"
    t.date    "creation_date"
    t.integer "update_freq"
    t.string  "resource_type"
    t.string  "data_overview"
    t.string  "serial_num"
    t.string  "make"
    t.string  "location"
    t.string  "uri"
    t.boolean "mirror_proxy"
  end

  create_table "streams", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.boolean  "private"
    t.float    "accuracy"
    t.float    "longitude"
    t.float    "latitude"
    t.string   "stream_type"
    t.string   "unit"
    t.float    "max_val"
    t.float    "min_val"
    t.boolean  "active"
    t.text     "tags"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "resource_id"
    t.integer  "user_id"
    t.float    "user_ranking"
    t.integer  "history_size"
    t.integer  "subscribers"
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_digest"
    t.string   "remember_token"
    t.boolean  "admin",           default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["remember_token"], name: "index_users_on_remember_token"

end
