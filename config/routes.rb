Rails.application.routes.draw do
  post "/telegram/webhook", to: "telegram/webhooks#create"
  get "/telegram/webhook", to: "telegram/webhooks#index"

  post "/repressions/webhook", to: "repressions/webhooks#create"
end
