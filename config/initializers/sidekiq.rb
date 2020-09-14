# frozen_string_literal: true

require 'sidekiq/worker_killer'

Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://redis:6379/0' }

  # config.server_middleware do |chain|
  #   chain.add Sidekiq::WorkerKiller, max_rss: 480
  # end
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://redis:6379/0' }
end
