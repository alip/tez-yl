# == Schema Information
#
# Table name: book_words
#
#  id               :integer          not null, primary key
#  content          :string(255)
#  lemma            :string(255)
#  pos              :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  raw_content      :text(65535)
#  location         :integer
#  stem             :string(255)
#  pos_v            :string(255)
#  entity           :string(255)
#  native           :boolean
#  auto_content     :text(65535)
#  book_sentence_id :integer
#  stop_word        :boolean          default(FALSE)
#  new_speak        :boolean          default(FALSE)
#  new_naming       :boolean          default(FALSE)
#  new_abbreviation :boolean          default(FALSE)
#
# Indexes
#
#  index_book_words_on_book_sentence_id  (book_sentence_id)
#

require 'test_helper'

class BookWordTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
