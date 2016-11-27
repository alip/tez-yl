class AddLanguageToBookSentences < ActiveRecord::Migration
  def change
    add_column :book_sentences, :language, :string
  end
end
