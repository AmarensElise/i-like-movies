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

ActiveRecord::Schema[7.1].define(version: 2025_03_09_220614) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "actors", force: :cascade do |t|
    t.integer "tmdb_id"
    t.string "name"
    t.date "birthday"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  add_foreign_key "roles", "actors"
  add_foreign_key "roles", "movies"
end
