class BookSentencesController < ApplicationController
  def index
    @grid = BookSentencesGrid.new(params[:book_sentences_grid]) do |scope|
      scope.page(params[:page])
    end
  end
end
