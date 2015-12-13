require 'test_helper'

class BookParagraphsControllerTest < ActionController::TestCase
  setup do
    @book_paragraph = book_paragraphs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:book_paragraphs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create book_paragraph" do
    assert_difference('BookParagraph.count') do
      post :create, book_paragraph: { book_section_id: @book_paragraph.book_section_id, content: @book_paragraph.content, index: @book_paragraph.index }
    end

    assert_redirected_to book_paragraph_path(assigns(:book_paragraph))
  end

  test "should show book_paragraph" do
    get :show, id: @book_paragraph
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @book_paragraph
    assert_response :success
  end

  test "should update book_paragraph" do
    patch :update, id: @book_paragraph, book_paragraph: { book_section_id: @book_paragraph.book_section_id, content: @book_paragraph.content, index: @book_paragraph.index }
    assert_redirected_to book_paragraph_path(assigns(:book_paragraph))
  end

  test "should destroy book_paragraph" do
    assert_difference('BookParagraph.count', -1) do
      delete :destroy, id: @book_paragraph
    end

    assert_redirected_to book_paragraphs_path
  end
end
