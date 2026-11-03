class VotesController < ApplicationController
  def create
    poll = Poll.find(params[:poll_id])
    option = poll.options.find(params[:option_id])

    poll.votes.create!(option: option, voter_token: params[:voter_token])
    render json: poll.reload.results, status: :created
  end
end
