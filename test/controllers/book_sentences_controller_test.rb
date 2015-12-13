require 'test_helper'

class BookSentencesControllerTest < ActionController::TestCase
  setup do
    @book_sentence = book_sentences(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:book_sentences)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create book_sentence" do
    assert_difference('BookSentence.count') do
      post :create, book_sentence: { book_paragraph_id: @book_sentence.book_paragraph_id, content: @book_sentence.content, index: @book_sentence.index }
    end

    assert_redirected_to book_sentence_path(assigns(:book_sentence))
  end

  test "should show book_sentence" do
    get :show, id: @book_sentence
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @book_sentence
    assert_response :success
  end

  test "should update book_sentence" do
    patch :update, id: @book_sentence, book_sentence: { book_paragraph_id: @book_sentence.book_paragraph_id, content: @book_sentence.content, index: @book_sentence.index }
    assert_redirected_to book_sentence_path(assigns(:book_sentence))
  end

  test "should destroy book_sentence" do
    assert_difference('BookSentence.count', -1) do
      delete :destroy, id: @book_sentence
    end

    assert_redirected_to book_sentences_path
  end
end
