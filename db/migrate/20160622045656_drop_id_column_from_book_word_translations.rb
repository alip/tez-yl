class DropIdColumnFromBookWordTranslations < ActiveRecord::Migration
  def change
    remove_column :book_word_translations, :id
  end
end
