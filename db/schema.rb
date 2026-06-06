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

ActiveRecord::Schema[8.1].define(version: 2026_06_06_201413) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "evidences", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "opportunity_id"
    t.bigint "scout_run_id", null: false
    t.string "signal_type"
    t.string "source", null: false
    t.text "summary"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "url"
    t.index ["opportunity_id"], name: "index_evidences_on_opportunity_id"
    t.index ["scout_run_id"], name: "index_evidences_on_scout_run_id"
    t.index ["signal_type"], name: "index_evidences_on_signal_type"
    t.index ["source"], name: "index_evidences_on_source"
  end

  create_table "opportunities", force: :cascade do |t|
    t.string "audience"
    t.integer "build_fit"
    t.datetime "created_at", null: false
    t.text "evidence_summary"
    t.jsonb "mvp_plan", default: [], null: false
    t.string "passport_id"
    t.string "passport_metadata_hash"
    t.string "passport_metadata_uri"
    t.string "passport_tx_hash"
    t.text "problem", null: false
    t.integer "score", null: false
    t.bigint "scout_run_id", null: false
    t.integer "time_fit"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["passport_id"], name: "index_opportunities_on_passport_id", unique: true
    t.index ["passport_metadata_hash"], name: "index_opportunities_on_passport_metadata_hash"
    t.index ["passport_tx_hash"], name: "index_opportunities_on_passport_tx_hash"
    t.index ["score"], name: "index_opportunities_on_score"
    t.index ["scout_run_id"], name: "index_opportunities_on_scout_run_id"
  end

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

  create_table "somnia_requests", force: :cascade do |t|
    t.string "agent_id", null: false
    t.string "agent_kind", default: "llm_inference", null: false
    t.string "callback_tx_hash"
    t.datetime "created_at", null: false
    t.jsonb "payload", default: {}, null: false
    t.string "request_id"
    t.string "request_tx_hash"
    t.jsonb "response", default: {}, null: false
    t.bigint "scout_run_id", null: false
    t.string "stage", default: "evaluation", null: false
    t.string "status", default: "draft", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_id"], name: "index_somnia_requests_on_agent_id"
    t.index ["agent_kind"], name: "index_somnia_requests_on_agent_kind"
    t.index ["callback_tx_hash"], name: "index_somnia_requests_on_callback_tx_hash"
    t.index ["request_id"], name: "index_somnia_requests_on_request_id", unique: true
    t.index ["request_tx_hash"], name: "index_somnia_requests_on_request_tx_hash"
    t.index ["scout_run_id"], name: "index_somnia_requests_on_scout_run_id"
    t.index ["stage"], name: "index_somnia_requests_on_stage"
    t.index ["status"], name: "index_somnia_requests_on_status"
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

  add_foreign_key "evidences", "opportunities"
  add_foreign_key "evidences", "scout_runs"
  add_foreign_key "opportunities", "scout_runs"
  add_foreign_key "scout_runs", "user_profiles"
  add_foreign_key "somnia_requests", "scout_runs"
end
