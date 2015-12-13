require 'test_helper'

class BookPartsControllerTest < ActionController::TestCase
  setup do
    @book_part = book_parts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:book_parts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create book_part" do
    assert_difference('BookPart.count') do
      post :create, book_part: { book_id: @book_part.book_id, content: @book_part.content, index: @book_part.index }
    end

    assert_redirected_to book_part_path(assigns(:book_part))
  end

  test "should show book_part" do
    get :show, id: @book_part
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @book_part
    assert_response :success
  end

  test "should update book_part" do
    patch :update, id: @book_part, book_part: { book_id: @book_part.book_id, content: @book_part.content, index: @book_part.index }
    assert_redirected_to book_part_path(assigns(:book_part))
  end

  test "should destroy book_part" do
    assert_difference('BookPart.count', -1) do
      delete :destroy, id: @book_part
    end

    assert_redirected_to book_parts_path
  end
end
