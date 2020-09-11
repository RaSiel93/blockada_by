Rails.application.routes.draw do
  post "/telegram/webhook", to: "telegram/webhooks#create"
end
