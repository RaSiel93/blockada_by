# frozen_string_literal: true

module Telegram
  class WebhooksController < ApplicationController
    def create
      Telegram::ResolveWebhookWorker.perform_async(params.permit!.to_h)
    end

    def index
      render json: { message: "HELLO" }
    end
  end
end
