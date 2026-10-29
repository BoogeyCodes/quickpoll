require "test_helper"

class VoteTest < ActiveSupport::TestCase
  setup do
    @poll = Poll.create!(question: "Tabs or spaces?")
    @tabs = @poll.options.create!(label: "Tabs")
    @spaces = @poll.options.create!(label: "Spaces")
  end

  test "a valid vote is accepted" do
    vote = @poll.votes.build(option: @tabs, voter_token: "voter-1")
    assert vote.valid?
  end

  test "requires a voter token" do
    vote = @poll.votes.build(option: @tabs, voter_token: nil)
    assert_not vote.valid?
    assert_includes vote.errors[:voter_token], "can't be blank"
  end

  test "one voter cannot vote twice in the same poll" do
    @poll.votes.create!(option: @tabs, voter_token: "voter-1")
    second = @poll.votes.build(option: @spaces, voter_token: "voter-1")
    assert_not second.valid?
    assert_includes second.errors[:voter_token], "has already voted in this poll"
  end

  test "the same voter token may vote in a different poll" do
    @poll.votes.create!(option: @tabs, voter_token: "voter-1")
    other = Poll.create!(question: "Cats or dogs?")
    cats = other.options.create!(label: "Cats")
    vote = other.votes.build(option: cats, voter_token: "voter-1")
    assert vote.valid?
  end

  test "rejects an option from another poll" do
    other = Poll.create!(question: "Cats or dogs?")
    foreign = other.options.create!(label: "Cats")
    vote = @poll.votes.build(option: foreign, voter_token: "voter-1")
    assert_not vote.valid?
    assert_includes vote.errors[:option], "does not belong to this poll"
  end

  test "rejects a vote on a closed poll" do
    @poll.update!(closed: true)
    vote = @poll.votes.build(option: @tabs, voter_token: "voter-1")
    assert_not vote.valid?
    assert_includes vote.errors[:base], "poll is closed"
  end
end
