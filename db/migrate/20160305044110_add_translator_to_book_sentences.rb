class AddTranslatorToBookSentences < ActiveRecord::Migration
  def change
    add_column :book_sentences, :translator, :string
  end
end
