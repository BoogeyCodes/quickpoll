require "test_helper"

class PollsControllerTest < ActionDispatch::IntegrationTest
  test "creates a poll with options" do
    post polls_url, params: { question: "Best editor?", options: ["Vim", "VS Code", "Emacs"] }, as: :json

    assert_response :created
    body = response.parsed_body
    assert_equal "Best editor?", body["question"]
    assert_equal 3, body["options"].size
    assert_equal 0, body["total_votes"]
  end

  test "rejects a poll with fewer than two options" do
    post polls_url, params: { question: "Only one?", options: ["Just this"] }, as: :json
    assert_response :unprocessable_entity
    assert_includes response.parsed_body["errors"].join, "at least two options"
  end

  test "rejects a poll with a blank question" do
    post polls_url, params: { question: "", options: ["A", "B"] }, as: :json
    assert_response :unprocessable_entity
    assert_includes response.parsed_body["errors"].join, "Question can't be blank"
  end

  test "shows a poll with results" do
    poll = create_poll
    get poll_url(poll), as: :json
    assert_response :success
    assert_equal poll.question, response.parsed_body["question"]
  end

  test "returns 404 for an unknown poll" do
    get poll_url(id: 999_999), as: :json
    assert_response :not_found
  end

  test "lists polls newest first" do
    create_poll(question: "First")
    create_poll(question: "Second")
    get polls_url, as: :json
    questions = response.parsed_body.map { |p| p["question"] }
    assert_equal ["Second", "First"], questions
  end

  test "closes a poll" do
    poll = create_poll
    post close_poll_url(poll), as: :json
    assert_response :success
    assert response.parsed_body["closed"]
  end

  private

  def create_poll(question: "Tabs or spaces?")
    poll = Poll.create!(question: question)
    poll.options.create!(label: "A")
    poll.options.create!(label: "B")
    poll
  end
end
