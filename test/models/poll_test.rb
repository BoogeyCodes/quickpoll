require "test_helper"

class PollTest < ActiveSupport::TestCase
  test "requires a question" do
    assert_not Poll.new(question: "").valid?
  end

  test "results report counts and percentages" do
    poll = Poll.create!(question: "Tabs or spaces?")
    tabs = poll.options.create!(label: "Tabs")
    spaces = poll.options.create!(label: "Spaces")
    poll.votes.create!(option: tabs, voter_token: "a")
    poll.votes.create!(option: tabs, voter_token: "b")
    poll.votes.create!(option: spaces, voter_token: "c")

    results = poll.results
    assert_equal 3, results[:total_votes]
    tabs_result = results[:options].find { |o| o[:id] == tabs.id }
    assert_equal 2, tabs_result[:votes]
    assert_in_delta 66.7, tabs_result[:percentage], 0.1
  end

  test "percentages are zero when there are no votes" do
    poll = Poll.create!(question: "Empty?")
    poll.options.create!(label: "A")
    assert_equal 0.0, poll.results[:options].first[:percentage]
  end

  test "destroying a poll removes its options and votes" do
    poll = Poll.create!(question: "Gone?")
    option = poll.options.create!(label: "A")
    poll.votes.create!(option: option, voter_token: "a")
    assert_difference ["Option.count", "Vote.count"], -1 do
      poll.destroy
    end
  end
end
