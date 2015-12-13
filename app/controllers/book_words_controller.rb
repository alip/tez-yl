class BookWordsController < ApplicationController
  before_action :set_book_word, only: [:show, :edit, :update, :destroy]

  # GET /book_words
  # GET /book_words.json
  def index
    @book_words = BookWord.all
  end

  # GET /book_words/1
  # GET /book_words/1.json
  def show
  end

  # GET /book_words/new
  def new
    @book_word = BookWord.new
  end

  # GET /book_words/1/edit
  def edit
  end

  # POST /book_words
  # POST /book_words.json
  def create
    @book_word = BookWord.new(book_word_params)

    respond_to do |format|
      if @book_word.save
        format.html { redirect_to @book_word, notice: 'Book word was successfully created.' }
        format.json { render :show, status: :created, location: @book_word }
      else
        format.html { render :new }
        format.json { render json: @book_word.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /book_words/1
  # PATCH/PUT /book_words/1.json
  def update
    respond_to do |format|
      if @book_word.update(book_word_params)
        format.html { redirect_to @book_word, notice: 'Book word was successfully updated.' }
        format.json { render :show, status: :ok, location: @book_word }
      else
        format.html { render :edit }
        format.json { render json: @book_word.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /book_words/1
  # DELETE /book_words/1.json
  def destroy
    @book_word.destroy
    respond_to do |format|
      format.html { redirect_to book_words_url, notice: 'Book word was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_book_word
      @book_word = BookWord.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def book_word_params
      params.require(:book_word).permit(:content, :lemma, :pos)
    end
end
