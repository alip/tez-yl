require 'test_helper'

class BookSectionsControllerTest < ActionController::TestCase
  setup do
    @book_section = book_sections(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:book_sections)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create book_section" do
    assert_difference('BookSection.count') do
      post :create, book_section: { book_part_id: @book_section.book_part_id, content: @book_section.content, index: @book_section.index }
    end

    assert_redirected_to book_section_path(assigns(:book_section))
  end

  test "should show book_section" do
    get :show, id: @book_section
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @book_section
    assert_response :success
  end

  test "should update book_section" do
    patch :update, id: @book_section, book_section: { book_part_id: @book_section.book_part_id, content: @book_section.content, index: @book_section.index }
    assert_redirected_to book_section_path(assigns(:book_section))
  end

  test "should destroy book_section" do
    assert_difference('BookSection.count', -1) do
      delete :destroy, id: @book_section
    end

    assert_redirected_to book_sections_path
  end
end
