# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_06_03_161807) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "scout_runs", force: :cascade do |t|
    t.string "callback_tx_hash"
    t.datetime "created_at", null: false
    t.text "goal", null: false
    t.string "result_hash"
    t.string "somnia_request_id"
    t.string "status", default: "draft", null: false
    t.string "tx_hash"
    t.datetime "updated_at", null: false
    t.bigint "user_profile_id", null: false
    t.string "wallet_address"
    t.index ["somnia_request_id"], name: "index_scout_runs_on_somnia_request_id", unique: true
    t.index ["status"], name: "index_scout_runs_on_status"
    t.index ["tx_hash"], name: "index_scout_runs_on_tx_hash"
    t.index ["user_profile_id"], name: "index_scout_runs_on_user_profile_id"
    t.index ["wallet_address"], name: "index_scout_runs_on_wallet_address"
  end

  create_table "user_profiles", force: :cascade do |t|
    t.integer "available_days"
    t.text "background"
    t.datetime "created_at", null: false
    t.string "github_url"
    t.string "linkedin_url"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "scout_runs", "user_profiles"
end
