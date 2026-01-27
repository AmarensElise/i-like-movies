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

ActiveRecord::Schema[7.1].define(version: 2026_01_27_141142) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "actors", force: :cascade do |t|
    t.integer "tmdb_id"
    t.string "name"
    t.date "birthday"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.index ["slug"], name: "index_actors_on_slug", unique: true
  end

  create_table "favorite_actors", force: :cascade do |t|
    t.bigint "actor_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "actor_id"], name: "index_favorite_actors_on_user_id_and_actor_id", unique: true
    t.index ["user_id"], name: "index_favorite_actors_on_user_id"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "list_items", force: :cascade do |t|
    t.bigint "list_id", null: false
    t.bigint "movie_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["list_id", "movie_id"], name: "index_list_items_on_list_id_and_movie_id", unique: true
    t.index ["list_id"], name: "index_list_items_on_list_id"
    t.index ["movie_id"], name: "index_list_items_on_movie_id"
  end

  create_table "lists", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "name"], name: "index_lists_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_lists_on_user_id"
  end

  create_table "movie_like_votes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "movie_like_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_like_id"], name: "index_movie_like_votes_on_movie_like_id"
    t.index ["user_id", "movie_like_id"], name: "index_movie_like_votes_on_user_id_and_movie_like_id", unique: true
    t.index ["user_id"], name: "index_movie_like_votes_on_user_id"
  end

  create_table "movie_likes", force: :cascade do |t|
    t.text "content", null: false
    t.bigint "user_id", null: false
    t.bigint "movie_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_id", "created_at"], name: "index_movie_likes_on_movie_id_and_created_at"
    t.index ["movie_id"], name: "index_movie_likes_on_movie_id"
    t.index ["user_id"], name: "index_movie_likes_on_user_id"
  end

  create_table "movies", force: :cascade do |t|
    t.integer "tmdb_id"
    t.string "title"
    t.date "release_date"
    t.string "poster_path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "vote_average"
    t.integer "runtime"
    t.string "genres"
    t.string "slug"
    t.index ["slug"], name: "index_movies_on_slug", unique: true
  end

  create_table "roles", force: :cascade do |t|
    t.bigint "movie_id", null: false
    t.bigint "actor_id", null: false
    t.string "character"
    t.integer "age_during_filming"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_roles_on_actor_id"
    t.index ["movie_id"], name: "index_roles_on_movie_id"
  end

  create_table "show_roles", force: :cascade do |t|
    t.bigint "show_id", null: false
    t.bigint "actor_id", null: false
    t.string "character"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_show_roles_on_actor_id"
    t.index ["show_id", "actor_id"], name: "index_show_roles_on_show_id_and_actor_id", unique: true
    t.index ["show_id"], name: "index_show_roles_on_show_id"
  end

  create_table "shows", force: :cascade do |t|
    t.integer "tmdb_id"
    t.string "name"
    t.date "first_air_date"
    t.date "last_air_date"
    t.string "poster_path"
    t.decimal "vote_average"
    t.string "genres"
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_shows_on_slug", unique: true
    t.index ["tmdb_id"], name: "index_shows_on_tmdb_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "viewings", force: :cascade do |t|
    t.bigint "movie_id", null: false
    t.date "watched_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["movie_id"], name: "index_viewings_on_movie_id"
    t.index ["user_id", "movie_id"], name: "index_viewings_on_user_id_and_movie_id", unique: true
    t.index ["user_id"], name: "index_viewings_on_user_id"
  end

  create_table "watchlist_items", force: :cascade do |t|
    t.bigint "movie_id", null: false
    t.text "pitch"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "movie_id"], name: "index_watchlist_items_on_user_id_and_movie_id", unique: true
    t.index ["user_id"], name: "index_watchlist_items_on_user_id"
  end

  add_foreign_key "favorite_actors", "actors"
  add_foreign_key "favorite_actors", "users"
  add_foreign_key "list_items", "lists"
  add_foreign_key "list_items", "movies"
  add_foreign_key "lists", "users"
  add_foreign_key "movie_like_votes", "movie_likes"
  add_foreign_key "movie_like_votes", "users"
  add_foreign_key "movie_likes", "movies"
  add_foreign_key "movie_likes", "users"
  add_foreign_key "roles", "actors"
  add_foreign_key "roles", "movies"
  add_foreign_key "show_roles", "actors"
  add_foreign_key "show_roles", "shows"
  add_foreign_key "viewings", "movies"
  add_foreign_key "viewings", "users"
  add_foreign_key "watchlist_items", "movies"
  add_foreign_key "watchlist_items", "users"
end
