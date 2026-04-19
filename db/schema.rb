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

ActiveRecord::Schema[7.1].define(version: 2026_04_19_000007) do
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

  create_table "blends", force: :cascade do |t|
    t.bigint "movie_id", null: false
    t.integer "ingredient1_id"
    t.integer "ingredient2_id"
    t.integer "hint_id"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_id"], name: "index_blends_on_movie_id"
    t.index ["user_id"], name: "index_blends_on_user_id"
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

  create_table "list_item_stickers", force: :cascade do |t|
    t.bigint "list_item_id", null: false
    t.bigint "sticker_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["list_item_id", "sticker_id"], name: "index_list_item_stickers_on_list_item_id_and_sticker_id", unique: true
  end

  create_table "list_items", force: :cascade do |t|
    t.bigint "list_id", null: false
    t.bigint "movie_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position"
    t.text "note"
    t.integer "rating"
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
    t.bigint "revenue"
    t.decimal "popularity", precision: 10, scale: 4
    t.integer "vote_count"
    t.integer "tmdb_collection_id"
    t.string "tmdb_collection_name"
    t.index ["revenue"], name: "index_movies_on_revenue"
    t.index ["slug"], name: "index_movies_on_slug", unique: true
    t.index ["tmdb_collection_id"], name: "index_movies_on_tmdb_collection_id"
    t.index ["vote_count", "popularity"], name: "index_movies_on_vote_count_and_popularity"
  end

  create_table "quiz_questions", force: :cascade do |t|
    t.bigint "quiz_id", null: false
    t.bigint "movie_id", null: false
    t.integer "position", null: false
    t.integer "guessed_year"
    t.integer "points_earned"
    t.datetime "answered_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_id"], name: "index_quiz_questions_on_movie_id"
    t.index ["quiz_id", "movie_id"], name: "index_quiz_questions_on_quiz_id_and_movie_id", unique: true
    t.index ["quiz_id", "position"], name: "index_quiz_questions_on_quiz_id_and_position", unique: true
    t.index ["quiz_id"], name: "index_quiz_questions_on_quiz_id"
  end

  create_table "quizzes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "status", default: "in_progress"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.integer "total_score", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "status"], name: "index_quizzes_on_user_id_and_status"
    t.index ["user_id"], name: "index_quizzes_on_user_id"
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

  create_table "same_movie_categories", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_same_movie_categories_on_user_id"
  end

  create_table "same_movie_categorizations", force: :cascade do |t|
    t.bigint "same_movie_category_id", null: false
    t.bigint "movie_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_id"], name: "index_same_movie_categorizations_on_movie_id"
    t.index ["same_movie_category_id", "movie_id"], name: "index_same_movie_categorizations_on_category_and_movie", unique: true
    t.index ["same_movie_category_id"], name: "index_same_movie_categorizations_on_same_movie_category_id"
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

  create_table "stickers", force: :cascade do |t|
    t.string "label", null: false
    t.string "color", null: false
    t.boolean "preset", default: false, null: false
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["preset"], name: "index_stickers_on_preset"
    t.index ["user_id"], name: "index_stickers_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.string "country_code"
    t.index "lower((username)::text)", name: "index_users_on_lower_username", unique: true
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

  create_table "watch_quiz_sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.jsonb "answers", default: {}
    t.bigint "chosen_movie_id"
    t.bigint "rejected_movie_id"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chosen_movie_id"], name: "index_watch_quiz_sessions_on_chosen_movie_id"
    t.index ["rejected_movie_id"], name: "index_watch_quiz_sessions_on_rejected_movie_id"
    t.index ["user_id"], name: "index_watch_quiz_sessions_on_user_id"
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

  add_foreign_key "blends", "movies"
  add_foreign_key "blends", "users"
  add_foreign_key "favorite_actors", "actors"
  add_foreign_key "favorite_actors", "users"
  add_foreign_key "list_item_stickers", "list_items"
  add_foreign_key "list_item_stickers", "stickers"
  add_foreign_key "list_items", "lists"
  add_foreign_key "list_items", "movies"
  add_foreign_key "lists", "users"
  add_foreign_key "movie_like_votes", "movie_likes"
  add_foreign_key "movie_like_votes", "users"
  add_foreign_key "movie_likes", "movies"
  add_foreign_key "movie_likes", "users"
  add_foreign_key "quiz_questions", "movies"
  add_foreign_key "quiz_questions", "quizzes"
  add_foreign_key "quizzes", "users"
  add_foreign_key "roles", "actors"
  add_foreign_key "roles", "movies"
  add_foreign_key "same_movie_categories", "users"
  add_foreign_key "same_movie_categorizations", "movies"
  add_foreign_key "same_movie_categorizations", "same_movie_categories"
  add_foreign_key "show_roles", "actors"
  add_foreign_key "show_roles", "shows"
  add_foreign_key "stickers", "users"
  add_foreign_key "viewings", "movies"
  add_foreign_key "viewings", "users"
  add_foreign_key "watch_quiz_sessions", "movies", column: "chosen_movie_id"
  add_foreign_key "watch_quiz_sessions", "movies", column: "rejected_movie_id"
  add_foreign_key "watch_quiz_sessions", "users"
  add_foreign_key "watchlist_items", "movies"
  add_foreign_key "watchlist_items", "users"
end
