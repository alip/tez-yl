class BookParagraphsController < ApplicationController
  before_action :set_book_paragraph, only: [:show, :edit, :update, :destroy]

  # GET /book_paragraphs
  # GET /book_paragraphs.json
  def index
    @grid = BookParagraphsGrid.new(params[:book_paragraphs_grid]) do |scope|
      scope.page(params[:page])
    end
  end

  # GET /book_paragraphs/1
  # GET /book_paragraphs/1.json
  def show
  end

  # GET /book_paragraphs/new
  def new
    @book_paragraph = BookParagraph.new
  end

  # GET /book_paragraphs/1/edit
  def edit
  end

  # POST /book_paragraphs
  # POST /book_paragraphs.json
  def create
    @book_paragraph = BookParagraph.new(book_paragraph_params)

    respond_to do |format|
      if @book_paragraph.save
        format.html { redirect_to @book_paragraph, notice: 'Book paragraph was successfully created.' }
        format.json { render :show, status: :created, location: @book_paragraph }
      else
        format.html { render :new }
        format.json { render json: @book_paragraph.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /book_paragraphs/1
  # PATCH/PUT /book_paragraphs/1.json
  def update
    respond_to do |format|
      if @book_paragraph.update(book_paragraph_params)
        format.html { redirect_to @book_paragraph, notice: 'Book paragraph was successfully updated.' }
        format.json { render :show, status: :ok, location: @book_paragraph }
      else
        format.html { render :edit }
        format.json { render json: @book_paragraph.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /book_paragraphs/1
  # DELETE /book_paragraphs/1.json
  def destroy
    @book_paragraph.destroy
    respond_to do |format|
      format.html { redirect_to book_paragraphs_url, notice: 'Book paragraph was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_book_paragraph
      @book_paragraph = BookParagraph.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def book_paragraph_params
      params.require(:book_paragraph).permit(:book_section_id, :index, :content)
    end
end
