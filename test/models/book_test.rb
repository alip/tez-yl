# == Schema Information
#
# Table name: books
#
#  id         :integer          not null, primary key
#  path       :string(255)
#  title      :string(255)
#  author     :string(255)
#  translator :string(255)
#  content    :text(65535)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  language   :string(255)
#

require 'test_helper'

class BookTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
