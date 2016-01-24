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

ActiveRecord::Schema.define(version: 20160123114403) do

  create_table "book_paragraphs", force: :cascade do |t|
    t.integer  "book_section_id", limit: 4
    t.integer  "location",        limit: 4
    t.text     "content",         limit: 65535
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.text     "raw_content",     limit: 65535
  end

  add_index "book_paragraphs", ["book_section_id"], name: "index_book_paragraphs_on_book_section_id", using: :btree

  create_table "book_parts", force: :cascade do |t|
    t.integer  "book_id",    limit: 4
    t.integer  "location",   limit: 4
    t.text     "content",    limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "book_parts", ["book_id"], name: "index_book_parts_on_book_id", using: :btree

  create_table "book_sections", force: :cascade do |t|
    t.integer  "book_part_id", limit: 4
    t.integer  "location",     limit: 4
    t.text     "content",      limit: 65535
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "book_sections", ["book_part_id"], name: "index_book_sections_on_book_part_id", using: :btree

  create_table "book_sentences", force: :cascade do |t|
    t.integer  "book_paragraph_id", limit: 4
    t.integer  "location",          limit: 4
    t.text     "content",           limit: 65535
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.text     "raw_content",       limit: 65535
    t.text     "auto_content",      limit: 65535
  end

  add_index "book_sentences", ["book_paragraph_id"], name: "index_book_sentences_on_book_paragraph_id", using: :btree

  create_table "book_sentences_words", id: false, force: :cascade do |t|
    t.integer "book_sentence_id", limit: 4
    t.integer "book_word_id",     limit: 4
  end

  add_index "book_sentences_words", ["book_sentence_id", "book_word_id"], name: "book_sentences_book_words_index", unique: true, using: :btree

  create_table "book_translations", id: false, force: :cascade do |t|
    t.integer "source_id", limit: 4
    t.integer "target_id", limit: 4
  end

  add_index "book_translations", ["source_id", "target_id"], name: "book_sentences_sentences_index", unique: true, using: :btree

  create_table "book_word_dependencies", id: false, force: :cascade do |t|
    t.integer "dependency", limit: 4
    t.integer "related_id", limit: 4
    t.integer "relater_id", limit: 4
  end

  add_index "book_word_dependencies", ["dependency", "related_id", "relater_id"], name: "book_word_dependencies_index", unique: true, using: :btree

  create_table "book_words", force: :cascade do |t|
    t.string   "content",      limit: 255
    t.string   "lemma",        limit: 255
    t.string   "pos",          limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.text     "raw_content",  limit: 65535
    t.integer  "location",     limit: 4
    t.string   "stem",         limit: 255
    t.string   "pos_v",        limit: 255
    t.string   "entity",       limit: 255
    t.boolean  "native"
    t.text     "auto_content", limit: 65535
  end

  create_table "books", force: :cascade do |t|
    t.string   "path",       limit: 255
    t.string   "title",      limit: 255
    t.string   "author",     limit: 255
    t.string   "translator", limit: 255
    t.text     "content",    limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "language",   limit: 255
  end

end
