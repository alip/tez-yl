# == Schema Information
#
# Table name: book_words
#
#  id           :integer          not null, primary key
#  content      :string(255)
#  lemma        :string(255)
#  pos          :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  raw_content  :text(65535)
#  location     :integer
#  stem         :string(255)
#  pos_v        :string(255)
#  entity       :string(255)
#  native       :boolean
#  auto_content :text(65535)
#

class BookWord < ActiveRecord::Base
  POS = {
    :noun      => %w[Noun NN NNP NNPS NNS].freeze,
    :adjective => %w[Adj Adj^DB JJ JJR JJS].freeze,
    :adverb    => %w[Adv Adv^DB RB RBR RBS WRB].freeze,
    :verb      => %w[Verb VB VBD VBG VBN VBP VBZ].freeze
  }.freeze

  has_and_belongs_to_many :book_sentences

  scope :in, -> (language) { includes(:book_sentences => [{:book_paragraph => {:book_section => {:book_part => [:book]}}}]).where(:books => Book.query_in(language)) }
  scope :by, -> (author_or_translator) { includes(:book_sentences => [:book_paragraph => {:book_section => {:book_part => [:book]}}]).where(:books => Book.query_by(author_or_translator)) }
  scope :with_type, -> (tag) { where(:pos => POS[tag]) }

  has_many :relateds, :class_name => 'BookWordDependency', :foreign_key => :relater_id
  has_many :relaters, :class_name => 'BookWordDependency', :foreign_key => :related_id
  has_many :related_words, :through => :relateds
  has_many :relater_words, :through => :relaters

  def root
    verb? ? self.lemma : self.stem
  end

  def verb?
    POS[:verb].include?(self.pos)
  end

  def clean_content
    cc = raw_content.gsub('\\', '').tr('“”', '""')

    # Strip quotation, if blank, pass through quotation.
    scc = cc.gsub(/["']/, '')

    r = (scc.blank? ? cc : scc)

    # Nilify blanks for easier compact()ion.
    r.blank? ? nil : r
  end
end
