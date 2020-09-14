# frozen_string_literal: true

require "evil-client"

module Telegram
  class ClientService < Evil::Client
    option :tg_token, default: proc { ENV['TG_TOKEN'] }

    path { "https://api.telegram.org/bot#{tg_token}/" }

    response 200 do |_status, _headers, body|
      JSON.parse(body.first, symbolize_names: true)
    end

    response 400 do |_status, _headers, body|
      body
    end

    response 403 do |_status, _headers, _body|
    end

    operation :get_me do
      path { "getMe" }
      http_method :post
    end

    operation :send_message do
      path { "sendMessage" }

      option :chat_id
      option :text, optional: true
      option :parse_mode, optional: true
      option :disable_web_page_preview, optional: true
      option :disable_notification, optional: true
      option :reply_to_message_id, optional: true
      option :reply_markup, optional: true
      option :parse_mode, optional: true, default: proc { 'Markdown' }

      body { options }

      http_method :post
    end
  end
end
