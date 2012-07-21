# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100805143145) do

  create_table "affili_net_infos", :force => true do |t|
    t.string  "gtin"
    t.string  "name"
    t.string  "image_url"
    t.integer "product_id"
  end

  add_index "affili_net_infos", ["gtin"], :name => "index_affili_net_infos_on_gtin"

  create_table "bestbuy_infos", :force => true do |t|
    t.string  "gtin"
    t.string  "company"
    t.string  "brand"
    t.string  "gpc"
    t.string  "product_name"
    t.string  "product_category"
    t.string  "model_number"
    t.text    "product_description"
    t.string  "last_update"
    t.string  "product_url"
    t.string  "image_url"
    t.integer "product_id"
  end

  add_index "bestbuy_infos", ["gtin"], :name => "index_bestbuy_infos_on_gtin"

  create_table "client_tokens", :force => true do |t|
    t.string   "token",      :null => false
    t.integer  "user_id",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "client_tokens", ["token"], :name => "index_client_tokens_on_token", :unique => true
  add_index "client_tokens", ["user_id"], :name => "index_client_tokens_on_user_id"

  create_table "comments", :force => true do |t|
    t.text     "body"
    t.integer  "product_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.float    "latitude"
    t.float    "longitude"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "download_notifications", :force => true do |t|
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "external_responses", :force => true do |t|
    t.string   "gtin",       :null => false
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.string   "name"
    t.string   "image_url"
    t.integer  "product_id"
  end

  add_index "external_responses", ["gtin"], :name => "index_codecheck_infos_on_gtin"

  create_table "product_requests", :force => true do |t|
    t.integer  "product_id", :null => false
    t.string   "session_id"
    t.text     "user_agent"
    t.datetime "created_at"
  end

  add_index "product_requests", ["product_id"], :name => "index_product_requests_on_product_id"
  add_index "product_requests", ["session_id"], :name => "index_product_requests_on_session_id"

  create_table "products", :force => true do |t|
    t.string   "gtin"
    t.string   "name"
    t.string   "image_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "user_updated_at"
  end

  create_table "products_users", :id => false, :force => true do |t|
    t.integer "product_id", :null => false
    t.integer "user_id",    :null => false
  end

  add_index "products_users", ["product_id", "user_id"], :name => "index_products_users_on_product_id_and_user_id", :unique => true

  create_table "ratings", :force => true do |t|
    t.integer  "user_id"
    t.integer  "product_id", :null => false
    t.string   "value",      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ratings", ["product_id"], :name => "index_ratings_on_product_id"
  add_index "ratings", ["user_id"], :name => "index_ratings_on_user_id"

  create_table "scans", :force => true do |t|
    t.string   "gtin",       :null => false
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "product_id"
    t.float    "latitude"
    t.float    "longitude"
  end

  add_index "scans", ["gtin"], :name => "index_scans_on_gtin"

  create_table "upc_database_infos", :force => true do |t|
    t.string  "gtin"
    t.string  "name"
    t.string  "quantity"
    t.integer "product_id"
  end

  add_index "upc_database_infos", ["gtin"], :name => "index_upc_database_infos_on_gtin"

  create_table "users", :force => true do |t|
    t.string   "twitter_id"
    t.string   "twitter_login"
    t.string   "twitter_access_token"
    t.string   "twitter_access_secret"
    t.string   "remember_token"
    t.string   "name"
    t.string   "profile_image_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "facebook_id",           :limit => 8
    t.string   "facebook_auth_token"
    t.datetime "inbox_seen_at"
  end

end
