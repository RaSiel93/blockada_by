# frozen_string_literal: true

module Repressions
  class WebhooksController < ApplicationController
    def create
      Repressions::ResolveWebhookWorker.perform_async(params.permit!.to_h)
    end
  end
end
