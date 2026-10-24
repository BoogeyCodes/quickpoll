class Vote < ApplicationRecord
  belongs_to :poll
  belongs_to :option

  validates :voter_token, presence: true,
                          uniqueness: { scope: :poll_id, message: "has already voted in this poll" }
  validate :option_belongs_to_poll
  validate :poll_is_open, on: :create

  private

  def option_belongs_to_poll
    return if option.nil? || poll.nil?

    errors.add(:option, "does not belong to this poll") if option.poll_id != poll.id
  end

  def poll_is_open
    errors.add(:base, "poll is closed") if poll&.closed?
  end
end
