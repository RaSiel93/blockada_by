# frozen_string_literal: true

module Telegram
  class RefreshDataWorker < BaseWorker
    def perform
      RefreshDataService.call
    end
  end
end
