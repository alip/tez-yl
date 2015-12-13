# == Schema Information
#
# Table name: book_words
#
#  id          :integer          not null, primary key
#  content     :string
#  lemma       :string
#  pos         :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  raw_content :text
#  location    :integer
#

require 'test_helper'

class BookWordTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
