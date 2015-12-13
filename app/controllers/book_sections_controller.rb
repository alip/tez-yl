class BookSectionsController < ApplicationController
  before_action :set_book_section, only: [:show, :edit, :update, :destroy]

  # GET /book_sections
  # GET /book_sections.json
  def index
    @book_sections = BookSection.all
  end

  # GET /book_sections/1
  # GET /book_sections/1.json
  def show
  end

  # GET /book_sections/new
  def new
    @book_section = BookSection.new
  end

  # GET /book_sections/1/edit
  def edit
  end

  # POST /book_sections
  # POST /book_sections.json
  def create
    @book_section = BookSection.new(book_section_params)

    respond_to do |format|
      if @book_section.save
        format.html { redirect_to @book_section, notice: 'Book section was successfully created.' }
        format.json { render :show, status: :created, location: @book_section }
      else
        format.html { render :new }
        format.json { render json: @book_section.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /book_sections/1
  # PATCH/PUT /book_sections/1.json
  def update
    respond_to do |format|
      if @book_section.update(book_section_params)
        format.html { redirect_to @book_section, notice: 'Book section was successfully updated.' }
        format.json { render :show, status: :ok, location: @book_section }
      else
        format.html { render :edit }
        format.json { render json: @book_section.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /book_sections/1
  # DELETE /book_sections/1.json
  def destroy
    @book_section.destroy
    respond_to do |format|
      format.html { redirect_to book_sections_url, notice: 'Book section was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_book_section
      @book_section = BookSection.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def book_section_params
      params.require(:book_section).permit(:book_part_id, :index, :content)
    end
end
