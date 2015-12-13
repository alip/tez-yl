class BookSentencesController < ApplicationController
  before_action :set_book_sentence, only: [:show, :edit, :update, :destroy]

  # GET /book_sentences
  # GET /book_sentences.json
  def index
    @book_sentences = BookSentence.all
  end

  # GET /book_sentences/1
  # GET /book_sentences/1.json
  def show
  end

  # GET /book_sentences/new
  def new
    @book_sentence = BookSentence.new
  end

  # GET /book_sentences/1/edit
  def edit
  end

  # POST /book_sentences
  # POST /book_sentences.json
  def create
    @book_sentence = BookSentence.new(book_sentence_params)

    respond_to do |format|
      if @book_sentence.save
        format.html { redirect_to @book_sentence, notice: 'Book sentence was successfully created.' }
        format.json { render :show, status: :created, location: @book_sentence }
      else
        format.html { render :new }
        format.json { render json: @book_sentence.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /book_sentences/1
  # PATCH/PUT /book_sentences/1.json
  def update
    respond_to do |format|
      if @book_sentence.update(book_sentence_params)
        format.html { redirect_to @book_sentence, notice: 'Book sentence was successfully updated.' }
        format.json { render :show, status: :ok, location: @book_sentence }
      else
        format.html { render :edit }
        format.json { render json: @book_sentence.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /book_sentences/1
  # DELETE /book_sentences/1.json
  def destroy
    @book_sentence.destroy
    respond_to do |format|
      format.html { redirect_to book_sentences_url, notice: 'Book sentence was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_book_sentence
      @book_sentence = BookSentence.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def book_sentence_params
      params.require(:book_sentence).permit(:book_paragraph_id, :index, :content)
    end
end
