# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_09_17_224010) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "hyp_experiment_user_trials", force: :cascade do |t|
    t.bigint "hyp_experiment_id"
    t.bigint "hyp_variant_id"
    t.boolean "converted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "idiot_id"
    t.index ["hyp_experiment_id", "idiot_id"], name: "uniq_experiment_user_trials_idx", unique: true
    t.index ["hyp_experiment_id"], name: "index_hyp_experiment_user_trials_on_hyp_experiment_id"
    t.index ["hyp_variant_id"], name: "index_hyp_experiment_user_trials_on_hyp_variant_id"
  end

  create_table "hyp_experiments", force: :cascade do |t|
    t.string "name", null: false
    t.float "alpha", default: 0.05, null: false
    t.float "power", default: 0.8, null: false
    t.float "control", null: false
    t.float "minimum_detectable_effect", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_hyp_experiments_on_name", unique: true
  end

  create_table "hyp_variants", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "hyp_experiment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hyp_experiment_id"], name: "index_hyp_variants_on_hyp_experiment_id"
  end

  create_table "idiots", force: :cascade do |t|
    t.string "name"
    t.integer "age"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "hyp_experiment_user_trials", "hyp_experiments"
  add_foreign_key "hyp_experiment_user_trials", "hyp_variants"
  add_foreign_key "hyp_experiment_user_trials", "idiots"
  add_foreign_key "hyp_variants", "hyp_experiments"
end
