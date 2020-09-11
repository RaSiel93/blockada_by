# frozen_string_literal: true

module Telegram
  class ResolveWebhookWorker < BaseWorker
    def perform(params)
      ResolveWebhookService.new.call(params.deep_symbolize_keys)
    end
  end
end
