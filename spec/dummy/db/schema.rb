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

ActiveRecord::Schema.define(version: 2019_04_27_221658) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "hyp_alternatives", force: :cascade do |t|
    t.string "name", null: false
    t.integer "trials", default: 0, null: false
    t.integer "conversions", default: 0, null: false
    t.bigint "hyp_experiment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hyp_experiment_id"], name: "index_hyp_alternatives_on_hyp_experiment_id"
  end

  create_table "hyp_experiments", force: :cascade do |t|
    t.string "name", null: false
    t.float "alpha", default: 0.05, null: false
    t.float "power", default: 0.8, null: false
    t.float "control", null: false
    t.float "minimum_detectable_effect", null: false
    t.integer "sample_size", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_hyp_experiments_on_name", unique: true
  end

  add_foreign_key "hyp_alternatives", "hyp_experiments"
end
