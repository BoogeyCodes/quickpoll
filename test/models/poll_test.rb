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

  test "leading_option returns the option with the most votes" do
    poll = Poll.create!(question: "Best language?")
    a = poll.options.create!(label: "Ruby")
    b = poll.options.create!(label: "Python")
    poll.votes.create!(option: a, voter_token: "x")
    poll.votes.create!(option: a, voter_token: "y")
    poll.votes.create!(option: b, voter_token: "z")
    assert_equal a, poll.leading_option
  end

  test "leading_option is nil with no votes" do
    poll = Poll.create!(question: "Quiet?")
    poll.options.create!(label: "A")
    assert_nil poll.leading_option
  end

  test "leading_option is nil on a tie for first" do
    poll = Poll.create!(question: "Tie?")
    a = poll.options.create!(label: "A")
    b = poll.options.create!(label: "B")
    poll.votes.create!(option: a, voter_token: "x")
    poll.votes.create!(option: b, voter_token: "y")
    assert_nil poll.leading_option
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
