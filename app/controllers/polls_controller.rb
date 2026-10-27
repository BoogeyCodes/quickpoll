class PollsController < ApplicationController
  def index
    polls = Poll.order(created_at: :desc)
    render json: polls.map(&:results)
  end

  def show
    poll = Poll.find(params[:id])
    render json: poll.results
  end

  def create
    poll = Poll.new(question: params[:question])
    Array(params[:options]).each { |label| poll.options.build(label: label) }

    if poll.options.size < 2
      return render json: { errors: ["a poll needs at least two options"] },
                    status: :unprocessable_entity
    end

    poll.save!
    render json: poll.results, status: :created
  end

  def close
    poll = Poll.find(params[:id])
    poll.update!(closed: true)
    render json: poll.results
  end
end
