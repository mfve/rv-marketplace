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

ActiveRecord::Schema[8.0].define(version: 2026_01_10_100006) do
  create_table "bookings", force: :cascade do |t|
    t.date "start_date"
    t.date "end_date"
    t.string "status"
    t.integer "user_id", null: false
    t.integer "rv_listing_id", null: false
    t.index ["rv_listing_id"], name: "index_bookings_on_rv_listing_id"
    t.index ["user_id"], name: "index_bookings_on_user_id"
  end

  create_table "devise_api_tokens", force: :cascade do |t|
    t.string "resource_owner_type", null: false
    t.bigint "resource_owner_id", null: false
    t.string "access_token", null: false
    t.string "refresh_token"
    t.integer "expires_in", null: false
    t.datetime "revoked_at"
    t.string "previous_refresh_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["access_token"], name: "index_devise_api_tokens_on_access_token"
    t.index ["previous_refresh_token"], name: "index_devise_api_tokens_on_previous_refresh_token"
    t.index ["refresh_token"], name: "index_devise_api_tokens_on_refresh_token"
    t.index ["resource_owner_type", "resource_owner_id"], name: "index_devise_api_tokens_on_resource_owner"
  end

  create_table "messages", force: :cascade do |t|
    t.string "content"
    t.integer "rv_listing_id", null: false
    t.integer "user_id", null: false
    t.index ["rv_listing_id"], name: "index_messages_on_rv_listing_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "rv_listings", force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.string "location"
    t.decimal "price_per_day"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_rv_listings_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
  end

  add_foreign_key "bookings", "rv_listings"
  add_foreign_key "bookings", "users"
  add_foreign_key "messages", "rv_listings"
  add_foreign_key "messages", "users"
  add_foreign_key "rv_listings", "users"
end
