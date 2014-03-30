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

ActiveRecord::Schema.define(version: 20140330154426) do

  create_table "airports", force: true do |t|
    t.string   "name"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "types"
    t.string   "size"
    t.integer  "status"
    t.string   "iso"
    t.string   "continent"
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "airports", ["code"], name: "index_airports_on_code", using: :btree

  create_table "flights", force: true do |t|
    t.string   "flight_radar_id"
    t.string   "registration_one"
    t.string   "registration_two"
    t.string   "aircraft_code"
    t.string   "aircraft_name"
    t.string   "departure_airport"
    t.string   "arrival_airport"
    t.string   "flight_no"
    t.string   "call_sign"
    t.string   "airline"
    t.text     "payload"
    t.integer  "scheduled_departure"
    t.integer  "scheduled_arrival"
    t.integer  "departure_time"
    t.integer  "arrival_time"
    t.integer  "eta"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "flights", ["flight_radar_id"], name: "index_flights_on_flight_radar_id", unique: true, using: :btree

  create_table "snapshots", force: true do |t|
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "track"
    t.integer  "altitude"
    t.integer  "speed"
    t.string   "squawk"
    t.string   "radar"
    t.integer  "vertical_speed"
    t.string   "flight_id"
    t.text     "payload"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "dodgy"
  end

  add_index "snapshots", ["flight_id"], name: "index_snapshots_on_flight_id", using: :btree

end
