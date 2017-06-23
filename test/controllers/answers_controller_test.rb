require 'test_helper'

class AnswersControllerTest < ActionController::TestCase
  setup do
    @answer = answers(:one)
  end

  test "should not create answer without login" do
    question = questions(:one)
    assert_no_difference('Answer.count') do
      post :create, params: { answer: { text: 'an answer', question_id: question.id } }
    end

    assert_redirected_to login_url
  end

  test "should create answer" do
    session[:user_id] = users(:sean).id
    question = questions(:one)
    assert_difference('Answer.count') do
      post :create, params: { answer: { text: 'an answer', question_id: question.id } }
    end

    assert_redirected_to question_path(question)
  end

  test "should not create answer without question" do
    session[:user_id] = users(:sean).id
    assert_no_difference('Answer.count') do
      post :create, params: { answer: { text: 'an answer' } }
    end
  end

  test "should update answer" do
    session[:user_id] = users(:sean).id
    patch :update, params: { id: answers(:one), answer: { text: 'updated text!' } }
    assert_redirected_to question_path(questions(:one))
  end

  test "should destroy answer" do
    session[:user_id] = users(:sean).id
    assert_difference('Answer.count', -1) do
      delete :destroy, params: { id: @answer }
    end
    assert_redirected_to questions(:one)
  end

  test "should nullify best answer when destoryed" do
    session[:user_id] = users(:sean).id
    q = questions(:two)
    assert_not_nil q.best_answer
    delete :destroy, params: { id: q.best_answer.id }
    q.reload
    assert_nil q.best_answer
  end

  test "should not destroy answer of another user" do
    session[:user_id] = users(:john).id
    assert_no_difference('Answer.count') do
      delete :destroy, params: { id: @answer }
    end
    assert_redirected_to questions(:one)
  end

  test "should get edit" do
    session[:user_id] = users(:sean).id
    get :edit, params: { id: @answer }
    assert_response :success
  end

  test "should not get edit for not your answer" do
    session[:user_id] = users(:john).id
    get :edit, params: { id: @answer }
    assert_redirected_to questions(:one)
  end

  test "should update question" do
    session[:user_id] = users(:sean).id
    patch :update, params: { id: @answer, answer: { text: 'changed my answer' } }
    @answer.reload
    assert_equal @answer.text, 'changed my answer'
    assert_redirected_to @answer.question
  end

  test "should not update question" do
    session[:user_id] = users(:john).id
    patch :update, params: { id: @answer, answer: { text: 'changed my answer' } }
    @answer.reload
    assert_not_equal @answer.text, 'changed my answer'
    assert_redirected_to @answer.question
  end

  test "should vote up" do
    session[:user_id] = users(:sean).id
    assert_equal @answer.total_votes, 1
    post :voteup, params: { id: @answer.id }
    @answer.reload
    assert_equal @answer.total_votes, 2
    post :voteup, params: { id: @answer.id }
    @answer.reload
    assert_equal @answer.total_votes, 2
  end

  test "should vote down" do
    session[:user_id] = users(:sean).id
    assert_equal @answer.total_votes, 1
    post :votedown, params: { id: @answer.id }
    @answer.reload
    assert_equal @answer.total_votes, 0
    post :votedown, params: { id: @answer.id }
    @answer.reload
    assert_equal @answer.total_votes, 0
  end
end
