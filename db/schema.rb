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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130213210738) do

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "comments", :force => true do |t|
    t.string   "content"
    t.integer  "user_id"
    t.string   "media_id"
    t.datetime "date_posted"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "follow_relationships", :force => true do |t|
    t.integer  "followed_id"
    t.integer  "follower_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "followed_pages", :force => true do |t|
    t.integer  "followed_page_id"
    t.integer  "follower_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "games", :force => true do |t|
    t.integer  "team_id"
    t.string   "opponent"
    t.integer  "average_price"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "game_rating"
    t.date     "date"
  end

  create_table "media", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "pages", :force => true do |t|
    t.string   "name"
    t.integer  "category_id"
    t.integer  "user_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "description"
  end

  create_table "searches", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "sections", :force => true do |t|
    t.integer  "team_id"
    t.integer  "average_price"
    t.integer  "std_dev"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "name"
    t.string   "seat_view_url"
  end

  add_index "sections", ["name"], :name => "index_sections_on_name"

  create_table "sounds", :force => true do |t|
    t.integer  "rating"
    t.string   "url"
    t.integer  "start"
    t.string   "title"
    t.integer  "uploaded"
    t.string   "description"
    t.integer  "user_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "stars", :force => true do |t|
    t.string   "name"
    t.decimal  "rating"
    t.integer  "team_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "teams", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.integer  "home_average_popularity"
    t.integer  "away_price_standard_deviation"
    t.string   "url"
    t.text     "section_standard_deviations"
    t.string   "conference"
    t.string   "record"
    t.string   "venue_name"
    t.string   "venue_address"
    t.string   "division"
    t.string   "last_5"
  end

  create_table "tickets", :force => true do |t|
    t.integer  "game_id"
    t.string   "url"
    t.integer  "stubhub_id"
    t.integer  "price"
    t.string   "row"
    t.integer  "quantity"
    t.integer  "section_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.decimal  "z_score"
  end

  create_table "users", :force => true do |t|
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "image"
    t.string   "location"
    t.string   "likes"
    t.string   "oauth_token"
  end

  create_table "videos", :force => true do |t|
    t.string   "type"
    t.string   "name"
    t.string   "url"
    t.integer  "rating"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "start"
    t.string   "title"
    t.integer  "uploaded"
    t.string   "description"
  end

end
