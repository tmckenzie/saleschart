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

ActiveRecord::Schema.define(version: 20190215040021) do

  create_table "accounts", force: :cascade do |t|
    t.integer  "accountable_id",   limit: 4
    t.string   "accountable_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_status",   limit: 4,   default: 0
  end

  create_table "features", force: :cascade do |t|
    t.integer "vendor_id", limit: 4,   null: false
    t.string  "name",      limit: 255
  end

  add_index "features", ["vendor_id", "name"], name: "index_vendor_features", unique: true, using: :btree

  create_table "job_details", force: :cascade do |t|
    t.integer  "job_id",          limit: 4,     null: false
    t.integer  "seq_num",         limit: 4
    t.string   "detail_type",     limit: 255
    t.text     "detail_value",    limit: 65535
    t.integer  "originable_id",   limit: 4
    t.string   "originable_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "job_details", ["job_id"], name: "index_job_details_on_job_id", using: :btree

  create_table "job_stats", force: :cascade do |t|
    t.integer  "job_id",     limit: 4,   null: false
    t.integer  "stat_value", limit: 4
    t.string   "stat_name",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "job_stats", ["job_id"], name: "index_job_stats_on_job_id", using: :btree

  create_table "jobs", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.string   "job_type",        limit: 255
    t.string   "job_class",       limit: 255
    t.boolean  "server",          limit: 1
    t.string   "status",          limit: 255
    t.integer  "account_id",      limit: 4
    t.integer  "total_count",     limit: 4
    t.integer  "succeeded_count", limit: 4
    t.integer  "failed_count",    limit: 4
    t.string   "results",         limit: 255
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "masters", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "product_sales", force: :cascade do |t|
    t.integer  "product_id", limit: 4,   null: false
    t.date     "sales_date"
    t.integer  "amount",     limit: 4
    t.string   "quantity",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "product_sales", ["product_id", "sales_date"], name: "uq_sale", unique: true, using: :btree

  create_table "products", force: :cascade do |t|
    t.string  "asin",        limit: 255
    t.string  "description", limit: 255
    t.integer "item_number", limit: 4
  end

  add_index "products", ["asin"], name: "index_products_on_asin", using: :btree

  create_table "upload_requests", force: :cascade do |t|
    t.integer  "npo_id",                  limit: 4
    t.integer  "user_id",                 limit: 4
    t.string   "request_type",            limit: 255
    t.string   "status",                  limit: 255
    t.string   "upload_file_name",        limit: 255
    t.string   "upload_content_type",     limit: 255
    t.integer  "upload_file_size",        limit: 4
    t.datetime "upload_updated_at"
    t.datetime "upload_file_finished_at"
    t.datetime "processing_started_at"
    t.datetime "processing_finished_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "originable_id",           limit: 4
    t.string   "originable_type",         limit: 255
    t.integer  "account_id",              limit: 4
  end

  create_table "user_sessions", force: :cascade do |t|
    t.integer  "user_id",       limit: 4
    t.string   "session_token", limit: 255
    t.datetime "expire_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_sessions", ["user_id"], name: "index_user_session_uq", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "",    null: false
    t.string   "encrypted_password",     limit: 255, default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.integer  "account_id",             limit: 4
    t.integer  "sign_in_count",          limit: 4
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.boolean  "vendor_admin",           limit: 1,   default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "vendors", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",      limit: 255
  end

end
