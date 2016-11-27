class BookSentencesController < ApplicationController
  def index
    flash.keep
    @grid = BookSentencesGrid.new(params[:book_sentences_grid]) do |scope|
      scope.page(params[:page]).per_page(30)
    end
  end

  def create
    added = 0
    removed = 0

    align = params.select{|x| x.start_with?('align')}.map{|k,v| [k.sub('align-', '').to_i, v.split(' ').map(&:to_i)]}.to_h
    align.each do |tid, sids|
      target_sentence = BookSentence.find(tid) rescue nil
      next if target_sentence.nil?
      current_sources = target_sentence.sources.map(&:source_id)

      add_aligns    = (sids - current_sources)
      remove_aligns = (current_sources - sids)

      add_aligns.each do |source_id|
        BookTranslation.find_or_create_by(:source_id => source_id, :target_id => tid)
        added += 1
      end

      BookTranslation.delete_all(['source_id IN (?) AND target_id = ?', remove_aligns.join(','), tid])
    end

    flash.keep
    redirect_to :back, :flash => { :alert => "Eşleme: #{added} eklendi #{removed} kaldırıldı."}
  end
end
