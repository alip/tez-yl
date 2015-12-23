class RenameTableBookSentenceSentencesToBookTranslations < ActiveRecord::Migration
  def change
    rename_table :book_sentences_sentences, :book_translations
  end
end
