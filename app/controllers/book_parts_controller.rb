class BookPartsController < ApplicationController
  before_action :set_book_part, only: [:show, :edit, :update, :destroy]

  # GET /book_parts
  # GET /book_parts.json
  def index
    @book_parts = BookPart.all
  end

  # GET /book_parts/1
  # GET /book_parts/1.json
  def show
  end

  # GET /book_parts/new
  def new
    @book_part = BookPart.new
  end

  # GET /book_parts/1/edit
  def edit
  end

  # POST /book_parts
  # POST /book_parts.json
  def create
    @book_part = BookPart.new(book_part_params)

    respond_to do |format|
      if @book_part.save
        format.html { redirect_to @book_part, notice: 'Book part was successfully created.' }
        format.json { render :show, status: :created, location: @book_part }
      else
        format.html { render :new }
        format.json { render json: @book_part.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /book_parts/1
  # PATCH/PUT /book_parts/1.json
  def update
    respond_to do |format|
      if @book_part.update(book_part_params)
        format.html { redirect_to @book_part, notice: 'Book part was successfully updated.' }
        format.json { render :show, status: :ok, location: @book_part }
      else
        format.html { render :edit }
        format.json { render json: @book_part.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /book_parts/1
  # DELETE /book_parts/1.json
  def destroy
    @book_part.destroy
    respond_to do |format|
      format.html { redirect_to book_parts_url, notice: 'Book part was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_book_part
      @book_part = BookPart.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def book_part_params
      params.require(:book_part).permit(:book_id, :index, :content)
    end
end
