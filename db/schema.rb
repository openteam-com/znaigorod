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

ActiveRecord::Schema.define(:version => 20150416034900) do

  create_table "account_settings", :force => true do |t|
    t.integer  "account_id"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.boolean  "dating",            :default => true
    t.boolean  "personal_digest",   :default => true
    t.boolean  "site_digest",       :default => true
    t.boolean  "statistics_digest", :default => true
  end

  add_index "account_settings", ["account_id"], :name => "index_account_settings_on_account_id"

  create_table "accounts", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "patronymic"
    t.string   "email"
    t.string   "rating"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.string   "nickname"
    t.string   "location"
    t.string   "gender"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.text     "avatar_url"
    t.date     "birthday"
    t.datetime "last_visit_at"
    t.text     "badge"
  end

  create_table "activities", :force => true do |t|
    t.text     "title"
    t.integer  "organization_id"
    t.integer  "user_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "status"
    t.string   "state"
    t.datetime "activity_at"
    t.integer  "contact_id"
    t.string   "kind"
  end

  add_index "activities", ["organization_id"], :name => "index_activities_on_organization_id"
  add_index "activities", ["user_id"], :name => "index_activities_on_user_id"

  create_table "addresses", :force => true do |t|
    t.string   "street"
    t.string   "house"
    t.integer  "organization_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "latitude"
    t.string   "longitude"
    t.string   "office"
    t.string   "region"
    t.string   "city"
  end

  add_index "addresses", ["organization_id"], :name => "index_addresses_on_organization_id"

  create_table "affiche_schedules", :force => true do |t|
    t.integer  "afisha_id"
    t.date     "starts_on"
    t.date     "ends_on"
    t.time     "starts_at"
    t.time     "ends_at"
    t.string   "holidays"
    t.string   "place"
    t.string   "hall"
    t.integer  "price_min"
    t.integer  "price_max"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "organization_id"
    t.string   "latitude"
    t.string   "longitude"
  end

  add_index "affiche_schedules", ["afisha_id"], :name => "index_affiche_schedules_on_affiche_id"

  create_table "afisha", :force => true do |t|
    t.string   "title"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.text     "description"
    t.string   "original_title"
    t.text     "poster_url"
    t.text     "trailer_code"
    t.text     "tag"
    t.string   "vfs_path"
    t.text     "image_url"
    t.datetime "distribution_starts_on"
    t.datetime "distribution_ends_on"
    t.string   "slug"
    t.boolean  "constant"
    t.integer  "yandex_metrika_page_views"
    t.integer  "vkontakte_likes"
    t.string   "vk_aid"
    t.string   "yandex_fotki_url"
    t.float    "popularity"
    t.float    "age_min"
    t.float    "age_max"
    t.float    "total_rating"
    t.string   "state"
    t.string   "poster_image_file_name"
    t.string   "poster_image_content_type"
    t.integer  "poster_image_file_size"
    t.datetime "poster_image_updated_at"
    t.text     "poster_image_url"
    t.integer  "user_id"
    t.text     "kind"
    t.string   "vk_event_url"
    t.integer  "fb_likes"
    t.integer  "odn_likes"
    t.boolean  "allow_auction"
    t.string   "poster_vk_id"
    t.datetime "promoted_at"
    t.text     "bkz_link"
  end

  add_index "afisha", ["slug"], :name => "index_affiches_on_slug", :unique => true
  add_index "afisha", ["user_id"], :name => "index_affiches_on_user_id"

  create_table "afisha_list_posters", :force => true do |t|
    t.integer  "position"
    t.datetime "expires_at"
    t.integer  "afisha_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "attachments", :force => true do |t|
    t.integer  "attachable_id"
    t.string   "attachable_type"
    t.text     "description"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "type"
    t.text     "thumbnail_url"
    t.integer  "height"
    t.integer  "width"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.text     "file_url"
    t.string   "file_image_url"
    t.integer  "position"
    t.integer  "user_id"
  end

  add_index "attachments", ["user_id"], :name => "index_attachments_on_user_id"

  create_table "banners", :force => true do |t|
    t.string   "title"
    t.string   "url"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.text     "image_url"
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "bets", :force => true do |t|
    t.integer  "afisha_id"
    t.integer  "number"
    t.integer  "amount"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "state"
    t.string   "codes"
  end

  add_index "bets", ["afisha_id"], :name => "index_bets_on_afisha_id"
  add_index "bets", ["user_id"], :name => "index_bets_on_user_id"

  create_table "car_sales_centers", :force => true do |t|
    t.text     "category"
    t.text     "description"
    t.text     "feature"
    t.string   "title"
    t.text     "offer"
    t.integer  "organization_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "car_sales_centers", ["organization_id"], :name => "index_car_sales_centers_on_organization_id"

  create_table "car_service_centers", :force => true do |t|
    t.text     "category"
    t.text     "description"
    t.text     "feature"
    t.string   "title"
    t.text     "offer"
    t.integer  "organization_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "car_service_centers", ["organization_id"], :name => "index_car_service_centers_on_organization_id"

  create_table "car_washes", :force => true do |t|
    t.text     "category"
    t.integer  "organization_id"
    t.string   "title"
    t.text     "description"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.text     "offer"
    t.text     "feature"
  end

  add_index "car_washes", ["organization_id"], :name => "index_car_washes_on_organization_id"

  create_table "comments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.text     "body"
    t.string   "ancestry"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "contacts", :force => true do |t|
    t.string   "full_name"
    t.string   "post"
    t.string   "phone"
    t.string   "mobile_phone"
    t.string   "email"
    t.string   "skype"
    t.string   "vkontakte"
    t.string   "facebook"
    t.integer  "organization_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "contacts", ["organization_id"], :name => "index_contacts_on_organization_id"

  create_table "contests", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.datetime "created_at",                                               :null => false
    t.datetime "updated_at",                                               :null => false
    t.string   "vfs_path"
    t.string   "slug"
    t.text     "og_description"
    t.string   "og_image_file_name"
    t.string   "og_image_content_type"
    t.integer  "og_image_file_size"
    t.datetime "og_image_updated_at"
    t.text     "og_image_url"
    t.text     "agreement"
    t.datetime "participation_ends_at"
    t.string   "type"
    t.string   "vote_type"
    t.string   "sms_prefix"
    t.integer  "short_number"
    t.string   "sms_secret"
    t.string   "default_sort",          :default => "by_id"
    t.string   "new_work_text",         :default => "Добавить фотографию"
  end

  add_index "contests", ["slug"], :name => "index_contests_on_slug", :unique => true

  create_table "copies", :force => true do |t|
    t.string   "state"
    t.string   "code"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "copy_payment_id"
    t.integer  "copyable_id"
    t.string   "copyable_type"
    t.integer  "row"
    t.integer  "seat"
  end

  add_index "copies", ["copy_payment_id"], :name => "index_tickets_on_payment_id"
  add_index "copies", ["copyable_id"], :name => "index_copies_on_copyable_id"
  add_index "copies", ["copyable_type"], :name => "index_copies_on_copyable_type"

  create_table "creations", :force => true do |t|
    t.integer  "organization_id"
    t.string   "title"
    t.text     "description"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.text     "category"
    t.text     "feature"
  end

  add_index "creations", ["organization_id"], :name => "index_creations_on_organization_id"

  create_table "cultures", :force => true do |t|
    t.text     "category"
    t.text     "feature"
    t.text     "offer"
    t.string   "payment"
    t.integer  "organization_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "title"
    t.text     "description"
  end

  create_table "currency_rates", :force => true do |t|
    t.string   "bank"
    t.string   "bank_link"
    t.float    "usd_sell"
    t.float    "usd_buy"
    t.float    "euro_sell"
    t.float    "euro_buy"
    t.float    "gold_sell"
    t.float    "gold_buy"
    t.float    "silver_sell"
    t.float    "silver_buy"
    t.float    "platinum_sell"
    t.float    "platinum_buy"
    t.float    "palladium_sell"
    t.float    "palladium_buy"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
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
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "discounts", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.text     "poster_url"
    t.string   "type"
    t.string   "poster_image_file_name"
    t.string   "poster_image_content_type"
    t.integer  "poster_image_file_size"
    t.datetime "poster_image_updated_at"
    t.text     "poster_image_url"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.string   "slug"
    t.float    "total_rating"
    t.text     "kind"
    t.integer  "number"
    t.integer  "origin_price"
    t.integer  "price"
    t.integer  "discounted_price"
    t.integer  "discount"
    t.string   "payment_system"
    t.string   "state"
    t.integer  "account_id"
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.boolean  "constant"
    t.boolean  "sale",                      :default => false
    t.text     "poster_vk_id"
    t.text     "terms"
    t.text     "supplier"
    t.text     "placeholder"
    t.integer  "afisha_id"
    t.string   "external_id"
    t.string   "discount_type"
    t.text     "email_addresses"
    t.boolean  "stale"
  end

  add_index "discounts", ["afisha_id"], :name => "index_discounts_on_afisha_id"

  create_table "entertainments", :force => true do |t|
    t.text     "category"
    t.text     "feature"
    t.text     "offer"
    t.string   "payment"
    t.integer  "organization_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "title"
    t.text     "description"
    t.string   "type"
  end

  add_index "entertainments", ["organization_id"], :name => "index_entertainments_on_organization_id"

  create_table "feature_organizations", :force => true do |t|
    t.integer  "feature_id"
    t.integer  "organization_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "feature_organizations", ["feature_id"], :name => "index_feature_organizations_on_feature_id"
  add_index "feature_organizations", ["organization_id"], :name => "index_feature_organizations_on_organization_id"

  create_table "features", :force => true do |t|
    t.string   "title"
    t.integer  "organization_category_id"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  create_table "feeds", :force => true do |t|
    t.integer  "feedable_id"
    t.string   "feedable_type"
    t.integer  "account_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "type_of_feedable"
  end

  add_index "feeds", ["account_id"], :name => "index_feeds_on_account_id"
  add_index "feeds", ["feedable_id"], :name => "index_feeds_on_feedable_id"

  create_table "friends", :force => true do |t|
    t.integer  "account_id"
    t.integer  "friendable_id"
    t.string   "friendable_type"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.boolean  "friendly",        :default => false
  end

  add_index "friends", ["account_id"], :name => "index_friends_on_account_id"
  add_index "friends", ["friendable_id"], :name => "index_friends_on_friendable_id"

  create_table "halls", :force => true do |t|
    t.string   "title"
    t.integer  "seating_capacity"
    t.integer  "organization_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "halls", ["organization_id"], :name => "index_halls_on_organization_id"

  create_table "hotels", :force => true do |t|
    t.text     "category"
    t.text     "description"
    t.text     "feature"
    t.string   "title"
    t.text     "offer"
    t.integer  "organization_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "hotels", ["organization_id"], :name => "index_hotels_on_organization_id"

  create_table "invitations", :force => true do |t|
    t.integer  "inviteable_id"
    t.string   "inviteable_type"
    t.integer  "account_id"
    t.string   "kind"
    t.string   "category"
    t.text     "description"
    t.string   "gender"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "invited_id"
  end

  add_index "invitations", ["inviteable_id"], :name => "index_invitations_on_inviteable_id"
  add_index "invitations", ["invited_id"], :name => "index_invitations_on_invited_id"

  create_table "link_counters", :force => true do |t|
    t.string   "link_type"
    t.string   "name"
    t.string   "human_name"
    t.integer  "count",      :default => 0
    t.string   "link"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "main_page_posters", :force => true do |t|
    t.integer  "afisha_id"
    t.integer  "position"
    t.datetime "expires_at"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "main_page_reviews", :force => true do |t|
    t.integer  "review_id"
    t.integer  "position"
    t.datetime "expires_at"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "main_page_reviews", ["review_id"], :name => "index_main_page_reviews_on_review_id"

  create_table "map_layers", :force => true do |t|
    t.string   "title"
    t.integer  "map_project_id"
    t.string   "slug"
    t.string   "image_url"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.string   "image_file_size"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
    t.string   "icon_image_url"
    t.string   "icon_image_file_name"
    t.string   "icon_image_content_type"
    t.string   "icon_image_file_size"
  end

  create_table "map_placemarks", :force => true do |t|
    t.text     "title"
    t.float    "latitude"
    t.float    "longitude"
    t.text     "image_url"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.string   "image_file_size"
    t.text     "url"
    t.string   "when"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "kind"
    t.text     "organization_title"
    t.text     "organization_url"
    t.datetime "expires_at"
  end

  create_table "map_projects", :force => true do |t|
    t.string   "title"
    t.string   "slug"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.string   "cluster_icon_url"
    t.string   "cluster_icon_file_name"
    t.string   "cluster_icon_content_type"
    t.string   "cluster_icon_file_size"
  end

  create_table "map_relations", :id => false, :force => true do |t|
    t.integer  "map_layer_id"
    t.integer  "map_placemark_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "meals", :force => true do |t|
    t.text     "category"
    t.text     "feature"
    t.text     "offer"
    t.string   "payment"
    t.text     "cuisine"
    t.integer  "organization_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "title"
    t.text     "description"
  end

  add_index "meals", ["organization_id"], :name => "index_meals_on_organization_id"

  create_table "members", :force => true do |t|
    t.integer  "memberable_id"
    t.string   "memberable_type"
    t.integer  "account_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "members", ["account_id"], :name => "index_members_on_account_id"
  add_index "members", ["memberable_id"], :name => "index_members_on_memberable_id"

  create_table "menu_positions", :force => true do |t|
    t.integer  "menu_id"
    t.string   "position"
    t.string   "title"
    t.text     "description"
    t.string   "price"
    t.string   "count"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.integer  "cooking_time"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.text     "image_url"
  end

  add_index "menu_positions", ["menu_id"], :name => "index_menu_positions_on_menu_id"

  create_table "menus", :force => true do |t|
    t.integer  "meal_id"
    t.string   "category"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "menus", ["meal_id"], :name => "index_menus_on_meal_id"

  create_table "messages", :force => true do |t|
    t.integer  "messageable_id"
    t.string   "messageable_type"
    t.integer  "account_id"
    t.integer  "producer_id"
    t.text     "body"
    t.string   "state"
    t.string   "kind"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "type"
    t.string   "producer_type"
    t.string   "invite_kind"
    t.string   "agreement"
  end

  add_index "messages", ["account_id"], :name => "index_messages_on_account_id"
  add_index "messages", ["messageable_id"], :name => "index_messages_on_messageable_id"

  create_table "offers", :force => true do |t|
    t.integer  "account_id"
    t.integer  "offerable_id"
    t.string   "offerable_type"
    t.string   "phone"
    t.text     "details"
    t.integer  "amount"
    t.string   "name"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "state"
    t.integer  "our_stake"
    t.integer  "organization_stake"
    t.string   "code"
  end

  add_index "offers", ["account_id"], :name => "index_offers_on_account_id"
  add_index "offers", ["offerable_id"], :name => "index_offers_on_offerable_id"

  create_table "organization_categories", :force => true do |t|
    t.string   "title"
    t.string   "ancestry"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "organization_categories", ["ancestry"], :name => "index_organization_categories_on_ancestry"

  create_table "organization_category_items", :force => true do |t|
    t.integer  "organization_category_id"
    t.integer  "organization_id"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  create_table "organization_stands", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "places"
    t.boolean  "guarded"
    t.boolean  "video_observation"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "organization_stands", ["organization_id"], :name => "index_organization_stands_on_organization_id"

  create_table "organizations", :force => true do |t|
    t.text     "title"
    t.text     "site"
    t.text     "email"
    t.text     "description"
    t.datetime "created_at",                                                  :null => false
    t.datetime "updated_at",                                                  :null => false
    t.text     "phone"
    t.string   "vfs_path"
    t.integer  "organization_id"
    t.text     "logotype_url"
    t.string   "slug"
    t.float    "rating"
    t.boolean  "non_cash"
    t.string   "priority_suborganization_kind"
    t.text     "comment"
    t.integer  "additional_rating"
    t.integer  "yandex_metrika_page_views"
    t.integer  "vkontakte_likes"
    t.string   "subdomain"
    t.integer  "user_id"
    t.string   "status"
    t.float    "total_rating"
    t.integer  "primary_organization_id"
    t.boolean  "ability_to_comment",            :default => true
    t.integer  "fb_likes"
    t.integer  "odn_likes"
    t.string   "poster_vk_id"
    t.integer  "situated_at"
    t.text     "page_meta_description"
    t.text     "page_meta_keywords"
    t.text     "page_meta_title"
    t.datetime "positive_activity_date"
    t.text     "og_description"
    t.text     "og_title"
    t.integer  "phone_show_counter",            :default => 0
    t.integer  "site_link_counter",             :default => 0
    t.string   "photo_block_title",             :default => "Фото"
    t.string   "discounts_block_title",         :default => "Скидки"
    t.string   "afisha_block_title",            :default => "Афиша"
    t.string   "reviews_block_title",           :default => "Обзоры"
    t.string   "comments_block_title",          :default => "Отзывы"
    t.string   "barter_status",                 :default => "no_information"
    t.string   "discounts_navigation_title"
    t.string   "photos_navigation_title"
    t.string   "afishas_navigation_title"
    t.string   "reviews_navigation_title"
    t.string   "address_navigation_title"
    t.integer  "csv_id"
  end

  add_index "organizations", ["slug"], :name => "index_organizations_on_slug", :unique => true
  add_index "organizations", ["user_id"], :name => "index_organizations_on_user_id"

  create_table "page_meta", :force => true do |t|
    t.text     "path"
    t.text     "title"
    t.text     "header"
    t.text     "keywords"
    t.text     "description"
    t.text     "introduction"
    t.text     "og_title"
    t.text     "og_description"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.string   "og_image_file_name"
    t.string   "og_image_content_type"
    t.integer  "og_image_file_size"
    t.datetime "og_image_updated_at"
    t.text     "og_image_url"
  end

  create_table "page_visits", :force => true do |t|
    t.text     "session"
    t.integer  "page_visitable_id"
    t.string   "page_visitable_type"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.integer  "user_id"
    t.text     "user_agent"
  end

  add_index "page_visits", ["page_visitable_id"], :name => "index_page_visits_on_page_visitable_id"
  add_index "page_visits", ["user_id"], :name => "index_page_visits_on_user_id"

  create_table "paperclip_attachments", :force => true do |t|
    t.integer  "attacheable_id"
    t.string   "attacheable_type"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.text     "attachment_url"
    t.string   "attachment_type"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "paperclip_attachments", ["attacheable_id", "attacheable_type"], :name => "index_paperclip_attachments_on_attacheable_fields"

  create_table "payments", :force => true do |t|
    t.integer  "paymentable_id"
    t.integer  "number"
    t.string   "phone"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "user_id"
    t.string   "paymentable_type"
    t.string   "type"
    t.float    "amount"
    t.text     "details"
    t.string   "state"
    t.string   "email"
  end

  add_index "payments", ["paymentable_id"], :name => "index_payments_on_paymentable_id"
  add_index "payments", ["paymentable_type"], :name => "index_payments_on_paymentable_type"
  add_index "payments", ["type"], :name => "index_payments_on_type"
  add_index "payments", ["user_id"], :name => "index_payments_on_user_id"

  create_table "photogalleries", :force => true do |t|
    t.string   "title"
    t.string   "slug"
    t.text     "description"
    t.string   "vfs_path"
    t.text     "og_description"
    t.string   "og_image_file_name"
    t.string   "og_image_content_type"
    t.integer  "og_image_file_size"
    t.datetime "og_image_updated_at"
    t.text     "og_image_url"
    t.text     "agreement"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
    t.boolean  "available_participation"
    t.text     "page_meta_description"
    t.text     "page_meta_keywords"
  end

  create_table "place_items", :force => true do |t|
    t.string   "url"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "title"
  end

  create_table "place_items_promotion_places", :force => true do |t|
    t.integer "place_item_id"
    t.integer "promotion_place_id"
  end

  create_table "places", :force => true do |t|
    t.integer  "placeable_id"
    t.string   "placeable_type"
    t.string   "address"
    t.string   "latitude"
    t.string   "longitude"
    t.integer  "organization_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "title"
  end

  add_index "places", ["organization_id"], :name => "index_places_on_organization_id"
  add_index "places", ["placeable_id"], :name => "index_places_on_placeable_id"

  create_table "ponominalu_tickets", :force => true do |t|
    t.integer  "afisha_id"
    t.string   "ponominalu_id"
    t.integer  "count"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.text     "raw_info"
    t.string   "title"
  end

  add_index "ponominalu_tickets", ["afisha_id"], :name => "index_ponominalu_tickets_on_afisha_id"

  create_table "pool_table_prices", :force => true do |t|
    t.integer  "pool_table_id"
    t.integer  "day"
    t.time     "from"
    t.time     "to"
    t.integer  "price"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "pool_table_prices", ["pool_table_id"], :name => "index_pool_table_prices_on_pool_table_id"

  create_table "pool_tables", :force => true do |t|
    t.integer  "size"
    t.integer  "count"
    t.string   "kind"
    t.integer  "billiard_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "pool_tables", ["billiard_id"], :name => "index_pool_tables_on_billiard_id"

  create_table "prices", :force => true do |t|
    t.string   "kind"
    t.integer  "value"
    t.integer  "count"
    t.string   "period"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "description"
    t.integer  "max_value"
    t.string   "type"
    t.integer  "context_id"
    t.string   "context_type"
    t.string   "day_kind"
  end

  create_table "promotion_places", :force => true do |t|
    t.integer  "promotion_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "position"
  end

  add_index "promotion_places", ["promotion_id"], :name => "index_promotion_places_on_promotion_id"

  create_table "promotions", :force => true do |t|
    t.string   "url"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "relations", :force => true do |t|
    t.integer  "master_id"
    t.string   "master_type"
    t.integer  "slave_id"
    t.string   "slave_type"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "relations", ["master_id"], :name => "index_relations_on_master_id"
  add_index "relations", ["slave_id"], :name => "index_relations_on_slave_id"

  create_table "reservations", :force => true do |t|
    t.integer  "reserveable_id"
    t.string   "reserveable_type"
    t.text     "placeholder"
    t.string   "phone"
    t.string   "title"
    t.float    "balance"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "reservations", ["reserveable_id"], :name => "index_reservations_on_reserveable_id"
  add_index "reservations", ["reserveable_type"], :name => "index_reservations_on_reserveable_type"

  create_table "review_category_items", :force => true do |t|
    t.integer  "organization_category_id"
    t.integer  "review_id"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  create_table "reviews", :force => true do |t|
    t.string   "title"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.string   "type"
    t.text     "content"
    t.string   "slug"
    t.text     "tag"
    t.text     "categories"
    t.string   "state"
    t.integer  "account_id"
    t.boolean  "allow_external_links"
    t.text     "video_url"
    t.text     "poster_image_url"
    t.string   "poster_image_file_name"
    t.string   "poster_image_content_type"
    t.integer  "poster_image_file_size"
    t.datetime "poster_image_updated_at"
    t.text     "poster_url"
    t.float    "rating"
    t.text     "cached_content_for_index"
    t.text     "cached_content_for_show"
    t.text     "poster_vk_id"
    t.boolean  "only_tomsk"
    t.integer  "contest_id"
    t.string   "old_slug"
  end

  create_table "roles", :force => true do |t|
    t.integer  "user_id"
    t.string   "role"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "roles", ["user_id"], :name => "index_roles_on_user_id"

  create_table "rooms", :force => true do |t|
    t.integer  "context_id"
    t.string   "context_type"
    t.string   "title"
    t.integer  "capacity"
    t.integer  "rooms_count"
    t.text     "description"
    t.text     "feature"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "salon_centers", :force => true do |t|
    t.text     "category"
    t.text     "description"
    t.text     "feature"
    t.string   "title"
    t.text     "offer"
    t.integer  "organization_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "salon_centers", ["organization_id"], :name => "index_salon_centers_on_organization_id"

  create_table "sauna_accessories", :force => true do |t|
    t.integer  "sauna_id"
    t.integer  "sheets"
    t.integer  "sneakers"
    t.integer  "bathrobes"
    t.integer  "towels"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.boolean  "ware"
  end

  add_index "sauna_accessories", ["sauna_id"], :name => "index_sauna_accessories_on_sauna_id"

  create_table "sauna_alcohols", :force => true do |t|
    t.integer  "sauna_id"
    t.integer  "ability_own"
    t.boolean  "sale"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "sauna_alcohols", ["sauna_id"], :name => "index_sauna_alcohols_on_sauna_id"

  create_table "sauna_brooms", :force => true do |t|
    t.integer  "sauna_id"
    t.integer  "ability"
    t.integer  "sale"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sauna_brooms", ["sauna_id"], :name => "index_sauna_brooms_on_sauna_id"

  create_table "sauna_child_stuffs", :force => true do |t|
    t.integer  "sauna_id"
    t.integer  "life_jacket"
    t.integer  "cartoons"
    t.integer  "games"
    t.integer  "rubber_ring"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "sauna_child_stuffs", ["sauna_id"], :name => "index_sauna_child_stuffs_on_sauna_id"

  create_table "sauna_hall_baths", :force => true do |t|
    t.integer  "sauna_hall_id"
    t.boolean  "russian"
    t.boolean  "finnish"
    t.boolean  "turkish"
    t.boolean  "japanese"
    t.boolean  "infrared"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "sauna_hall_baths", ["sauna_hall_id"], :name => "index_sauna_hall_baths_on_sauna_hall_id"

  create_table "sauna_hall_capacities", :force => true do |t|
    t.integer  "sauna_hall_id"
    t.integer  "default"
    t.integer  "maximal"
    t.integer  "extra_guest_cost"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "sauna_hall_entertainments", :force => true do |t|
    t.integer  "sauna_hall_id"
    t.integer  "karaoke"
    t.integer  "tv"
    t.integer  "billiard"
    t.integer  "ping_pong"
    t.integer  "hookah"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "aerohockey"
    t.integer  "checkers"
    t.integer  "chess"
    t.integer  "backgammon"
    t.integer  "guitar"
  end

  add_index "sauna_hall_entertainments", ["sauna_hall_id"], :name => "index_sauna_hall_entertainments_on_sauna_hall_id"

  create_table "sauna_hall_interiors", :force => true do |t|
    t.integer  "sauna_hall_id"
    t.integer  "floors"
    t.integer  "lounges"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.boolean  "pit"
    t.boolean  "pylon"
    t.boolean  "barbecue"
  end

  add_index "sauna_hall_interiors", ["sauna_hall_id"], :name => "index_sauna_hall_interiors_on_sauna_hall_id"

  create_table "sauna_hall_pools", :force => true do |t|
    t.integer  "sauna_hall_id"
    t.string   "size"
    t.boolean  "contraflow"
    t.boolean  "geyser"
    t.boolean  "waterfall"
    t.string   "water_filter"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "jacuzzi"
    t.integer  "bucket"
  end

  add_index "sauna_hall_pools", ["sauna_hall_id"], :name => "index_sauna_hall_pools_on_sauna_hall_id"

  create_table "sauna_hall_schedules", :force => true do |t|
    t.integer  "sauna_hall_id"
    t.integer  "day"
    t.time     "from"
    t.time     "to"
    t.integer  "price"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "sauna_hall_schedules", ["sauna_hall_id"], :name => "index_sauna_hall_schedules_on_sauna_hall_id"

  create_table "sauna_halls", :force => true do |t|
    t.integer  "sauna_id"
    t.string   "title"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.text     "vfs_path"
    t.text     "description"
  end

  add_index "sauna_halls", ["sauna_id"], :name => "index_sauna_halls_on_sauna_id"

  create_table "sauna_massages", :force => true do |t|
    t.integer  "sauna_id"
    t.integer  "classical"
    t.integer  "spa"
    t.integer  "anticelltilitis"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "sauna_massages", ["sauna_id"], :name => "index_sauna_massages_on_sauna_id"

  create_table "sauna_oils", :force => true do |t|
    t.integer  "sauna_id"
    t.integer  "ability"
    t.boolean  "sale"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sauna_oils", ["sauna_id"], :name => "index_sauna_oils_on_sauna_id"

  create_table "sauna_stuffs", :force => true do |t|
    t.integer  "sauna_id"
    t.integer  "wifi"
    t.integer  "safe"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sauna_stuffs", ["sauna_id"], :name => "index_sauna_stuffs_on_sauna_id"

  create_table "saunas", :force => true do |t|
    t.text     "category"
    t.text     "feature"
    t.text     "offer"
    t.string   "payment"
    t.integer  "organization_id"
    t.string   "title"
    t.text     "description"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "schedules", :force => true do |t|
    t.integer  "day"
    t.time     "from"
    t.time     "to"
    t.integer  "organization_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.boolean  "holiday"
  end

  create_table "section_pages", :force => true do |t|
    t.string   "title"
    t.text     "content"
    t.integer  "section_id"
    t.string   "poster_image_url"
    t.string   "poster_image_file_name"
    t.string   "poster_image_content_type"
    t.string   "poster_image_file_size"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.string   "vfs_path"
    t.integer  "position"
  end

  create_table "sections", :force => true do |t|
    t.string   "title"
    t.integer  "organization_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "position"
    t.string   "navigation_title"
  end

  create_table "services", :force => true do |t|
    t.text     "title"
    t.text     "feature"
    t.text     "age"
    t.string   "context_type"
    t.integer  "context_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.text     "category"
    t.text     "description"
    t.text     "offer"
    t.string   "kind"
    t.integer  "min_value"
  end

  create_table "shops", :force => true do |t|
    t.integer  "organization_id"
    t.text     "category"
    t.text     "feature"
    t.text     "offer"
    t.string   "payment"
    t.string   "title"
    t.text     "description"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "shops", ["organization_id"], :name => "index_shops_on_organization_id"

  create_table "showings", :force => true do |t|
    t.integer  "afisha_id"
    t.string   "place"
    t.datetime "starts_at"
    t.integer  "price_min"
    t.string   "hall"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.datetime "ends_at"
    t.integer  "price_max"
    t.integer  "organization_id"
    t.string   "latitude"
    t.string   "longitude"
  end

  add_index "showings", ["afisha_id"], :name => "index_showings_on_affiche_id"

  create_table "sms_claims", :force => true do |t|
    t.string   "name"
    t.string   "phone"
    t.text     "details"
    t.integer  "claimed_id"
    t.string   "claimed_type"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "sms_votes", :force => true do |t|
    t.datetime "vote_date"
    t.text     "sid"
    t.string   "sms_text"
    t.integer  "sms_id"
    t.string   "prefix"
    t.string   "phone"
    t.integer  "work_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "smses", :force => true do |t|
    t.string   "phone"
    t.string   "status"
    t.integer  "smsable_id"
    t.string   "smsable_type"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.text     "message"
  end

  create_table "social_links", :force => true do |t|
    t.integer  "organization_id"
    t.text     "title"
    t.text     "url"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "social_links", ["organization_id"], :name => "index_social_links_on_organization_id"

  create_table "sports", :force => true do |t|
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "organization_id"
    t.string   "title"
    t.text     "description"
    t.text     "category"
    t.text     "feature"
  end

  create_table "teaser_items", :force => true do |t|
    t.integer  "teaser_id"
    t.string   "image_content_type"
    t.string   "image_file_name"
    t.string   "image_file_size"
    t.string   "image_url"
    t.string   "url"
    t.string   "link_text"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.text     "description"
  end

  create_table "teasers", :force => true do |t|
    t.integer  "items_quantity"
    t.string   "border_color"
    t.string   "title"
    t.string   "slug"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "tickets", :force => true do |t|
    t.integer  "afisha_id"
    t.integer  "number"
    t.float    "original_price"
    t.float    "price"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.text     "description"
    t.datetime "stale_at"
    t.float    "organization_price"
    t.text     "email_addresses"
    t.integer  "undertow"
    t.string   "state"
    t.string   "payment_system"
    t.string   "short_description"
  end

  add_index "tickets", ["afisha_id"], :name => "index_ticket_infos_on_affiche_id"

  create_table "travels", :force => true do |t|
    t.text     "category"
    t.text     "description"
    t.text     "feature"
    t.string   "title"
    t.text     "offer"
    t.integer  "organization_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "travels", ["organization_id"], :name => "index_travels_on_organization_id"

  create_table "user_ratings", :force => true do |t|
    t.integer  "user_id"
    t.integer  "rateable_id"
    t.string   "rateable_type"
    t.integer  "value"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "user_ratings", ["rateable_id", "rateable_type"], :name => "index_user_ratings_on_rateable_id_and_rateable_type"
  add_index "user_ratings", ["user_id"], :name => "index_user_ratings_on_user_id"

  create_table "users", :force => true do |t|
    t.integer  "roles_mask"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.string   "uid"
    t.integer  "sign_in_count",       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "provider"
    t.text     "auth_raw_info"
    t.datetime "remember_created_at"
    t.string   "remember_token"
    t.string   "rating"
    t.integer  "account_id"
  end

  add_index "users", ["account_id"], :name => "index_users_on_account_id"

  create_table "versions", :force => true do |t|
    t.text     "body"
    t.integer  "versionable_id"
    t.string   "versionable_type"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "versions", ["versionable_id"], :name => "index_versions_on_versionable_id"

  create_table "virtual_tours", :force => true do |t|
    t.string   "link"
    t.integer  "tourable_id"
    t.string   "tourable_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "virtual_tours", ["tourable_id", "tourable_type"], :name => "index_virtual_tours_on_tourable_id_and_tourable_type"

  create_table "visits", :force => true do |t|
    t.integer  "user_id"
    t.integer  "visitable_id"
    t.string   "visitable_type"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "visits", ["user_id"], :name => "index_visits_on_user_id"
  add_index "visits", ["visitable_id"], :name => "index_visits_on_visitable_id"

  create_table "votes", :force => true do |t|
    t.integer  "user_id"
    t.boolean  "like",          :default => false
    t.integer  "voteable_id"
    t.string   "voteable_type"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.string   "source"
  end

  add_index "votes", ["user_id"], :name => "index_votes_on_user_id"
  add_index "votes", ["voteable_id"], :name => "index_votes_on_voteable_id"

  create_table "webanketas", :force => true do |t|
    t.text     "text"
    t.datetime "expires_at"
    t.integer  "context_id"
    t.string   "context_type"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "webanketas", ["context_id"], :name => "index_webanketas_on_context_id"

  create_table "webcams", :force => true do |t|
    t.string   "kind"
    t.text     "title"
    t.text     "slug"
    t.text     "url"
    t.text     "parameters"
    t.text     "cab"
    t.integer  "width"
    t.integer  "height"
    t.text     "address"
    t.string   "latitude"
    t.string   "longitude"
    t.boolean  "state"
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
    t.text     "snapshot_url"
    t.string   "snapshot_image_file_name"
    t.string   "snapshot_image_content_type"
    t.integer  "snapshot_image_file_size"
    t.datetime "snapshot_image_updated_at"
    t.text     "snapshot_image_url"
    t.boolean  "our_cam",                     :default => false
  end

  add_index "webcams", ["slug"], :name => "index_webcams_on_slug"

  create_table "works", :force => true do |t|
    t.text     "image_url"
    t.string   "author_info"
    t.integer  "context_id"
    t.string   "title"
    t.text     "description"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.string   "slug"
    t.integer  "vk_likes"
    t.integer  "account_id"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.string   "context_type"
    t.float    "rating"
    t.string   "video_url"
    t.integer  "code"
    t.string   "type"
    t.text     "video_content"
    t.integer  "sms_counter",        :default => 0
  end

  add_index "works", ["account_id"], :name => "index_works_on_account_id"
  add_index "works", ["context_id"], :name => "index_works_on_contest_id"
  add_index "works", ["slug"], :name => "index_works_on_slug", :unique => true

end
