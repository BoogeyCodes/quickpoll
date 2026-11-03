class Poll < ApplicationRecord
  has_many :options, dependent: :destroy
  has_many :votes, dependent: :destroy

  validates :question, presence: true

  # Serialised form returned by the API, including vote counts and percentages.
  def results
    total = votes.size
    {
      id: id,
      question: question,
      closed: closed,
      total_votes: total,
      options: options.map do |option|
        count = option.votes.size
        {
          id: option.id,
          label: option.label,
          votes: count,
          percentage: total.zero? ? 0.0 : (count * 100.0 / total).round(1)
        }
      end
    }
  end

  # The option currently in the lead, or nil when there are no votes or a tie for first.
  def leading_option
    ranked = options.sort_by { |option| -option.votes.size }
    return nil if ranked.empty? || ranked.first.votes.size.zero?
    return nil if ranked.size > 1 && ranked.first.votes.size == ranked.second.votes.size

    ranked.first
  end
end
