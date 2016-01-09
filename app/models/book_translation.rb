# == Schema Information
#
# Table name: book_translations
#
#  source_id :integer
#  target_id :integer
#
# Indexes
#
#  book_sentences_sentences_index  (source_id,target_id) UNIQUE
#

class BookTranslation < ActiveRecord::Base
  belongs_to :source_sentence, :class_name => 'BookSentence', :foreign_key => :source_id
  belongs_to :target_sentence, :class_name => 'BookSentence', :foreign_key => :target_id
end
