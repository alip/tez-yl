# == Schema Information
#
# Table name: book_sentences
#
#  id                :integer          not null, primary key
#  book_paragraph_id :integer
#  location          :integer
#  content           :text(65535)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  raw_content       :text(65535)
#  auto_content      :text(65535)
#  translator        :string(255)
#  language          :string(255)
#  author            :string(255)
#  shifts            :integer
#  flags             :integer
#  ttr_section       :integer
#  ttr_subsection    :integer
#
# Indexes
#
#  index_book_sentences_on_book_paragraph_id  (book_paragraph_id)
#

require 'test_helper'

class BookSentenceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
