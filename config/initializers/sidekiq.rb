# frozen_string_literal: true

require 'sidekiq/worker_killer'

url = Rails.env.production? ? 'redis://redis:6379/0' : 'redis://127.0.0.1:6379/0'


Sidekiq.configure_server do |config|
  config.redis = { url: url }

  # config.server_middleware do |chain|
  #   chain.add Sidekiq::WorkerKiller, max_rss: 480
  # end
end

Sidekiq.configure_client do |config|
  config.redis = { url: url }
end
