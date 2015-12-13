require 'test_helper'

class BookWordsControllerTest < ActionController::TestCase
  setup do
    @book_word = book_words(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:book_words)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create book_word" do
    assert_difference('BookWord.count') do
      post :create, book_word: { content: @book_word.content, lemma: @book_word.lemma, pos: @book_word.pos }
    end

    assert_redirected_to book_word_path(assigns(:book_word))
  end

  test "should show book_word" do
    get :show, id: @book_word
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @book_word
    assert_response :success
  end

  test "should update book_word" do
    patch :update, id: @book_word, book_word: { content: @book_word.content, lemma: @book_word.lemma, pos: @book_word.pos }
    assert_redirected_to book_word_path(assigns(:book_word))
  end

  test "should destroy book_word" do
    assert_difference('BookWord.count', -1) do
      delete :destroy, id: @book_word
    end

    assert_redirected_to book_words_path
  end
end
