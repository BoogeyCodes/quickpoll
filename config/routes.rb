Rails.application.routes.draw do
  get "up", to: ->(_env) { [200, { "Content-Type" => "application/json" }, ['{"status":"ok"}']] }

  resources :polls, only: %i[index show create] do
    member do
      post :close
    end
    resources :votes, only: %i[create]
  end
end
