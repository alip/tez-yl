class BookTranslation < ActiveRecord::Base
  belongs_to :source_sentence, :class_name => 'BookSentence', :foreign_key => :source_id
  belongs_to :target_sentence, :class_name => 'BookSentence', :foreign_key => :target_id
end
