class AddTtrSectionToBookSentences < ActiveRecord::Migration
  def change
    add_column :book_sentences, :ttr_section, :integer
    add_column :book_sentences, :ttr_subsection, :integer
  end
end
