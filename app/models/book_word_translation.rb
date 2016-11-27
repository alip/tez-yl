# == Schema Information
#
# Table name: book_word_translations
#
#  source_id :integer
#  target_id :integer
#
# Indexes
#
#  book_word_translations_index  (source_id,target_id) UNIQUE
#

class BookWordTranslation < ActiveRecord::Base
  belongs_to :source_word, :class_name => 'BookWord', :foreign_key => :source_id
  belongs_to :target_word, :class_name => 'BookWord', :foreign_key => :target_id
end
