require "test_helper"

class VotesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @poll = Poll.create!(question: "Tabs or spaces?")
    @tabs = @poll.options.create!(label: "Tabs")
    @spaces = @poll.options.create!(label: "Spaces")
  end

  test "casting a vote returns updated results" do
    post poll_votes_url(@poll), params: { option_id: @tabs.id, voter_token: "voter-1" }, as: :json

    assert_response :created
    body = response.parsed_body
    assert_equal 1, body["total_votes"]
    tabs = body["options"].find { |o| o["id"] == @tabs.id }
    assert_equal 1, tabs["votes"]
    assert_equal 100.0, tabs["percentage"]
  end

  test "a voter cannot vote twice" do
    post poll_votes_url(@poll), params: { option_id: @tabs.id, voter_token: "voter-1" }, as: :json
    post poll_votes_url(@poll), params: { option_id: @spaces.id, voter_token: "voter-1" }, as: :json

    assert_response :unprocessable_entity
    assert_includes response.parsed_body["errors"].join, "already voted"
  end

  test "voting on a closed poll is rejected" do
    @poll.update!(closed: true)
    post poll_votes_url(@poll), params: { option_id: @tabs.id, voter_token: "voter-1" }, as: :json
    assert_response :unprocessable_entity
    assert_includes response.parsed_body["errors"].join, "poll is closed"
  end

  test "voting for an option from another poll is 404" do
    other = Poll.create!(question: "Cats or dogs?")
    foreign = other.options.create!(label: "Cats")
    post poll_votes_url(@poll), params: { option_id: foreign.id, voter_token: "voter-1" }, as: :json
    assert_response :not_found
  end

  test "percentages reflect the split across voters" do
    post poll_votes_url(@poll), params: { option_id: @tabs.id, voter_token: "a" }, as: :json
    post poll_votes_url(@poll), params: { option_id: @tabs.id, voter_token: "b" }, as: :json
    post poll_votes_url(@poll), params: { option_id: @spaces.id, voter_token: "c" }, as: :json

    body = response.parsed_body
    assert_equal 3, body["total_votes"]
    tabs = body["options"].find { |o| o["id"] == @tabs.id }
    assert_in_delta 66.7, tabs["percentage"], 0.1
  end
end
