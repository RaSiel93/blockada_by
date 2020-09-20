# frozen_string_literal: true

module Repressions
  class ResolveWebhookService < BaseService
    ADMIN_ID = ENV.fetch("REPRESSIONS_ADMIN").to_s

    def call(params)
      case params
      in { message: { from: { is_bot: true } } }
      in { message: { text: "/start", chat: { id: chat_id } } }
        send_main_menu(chat_id)
      in { message: { text: message, chat: { id: chat_id }, from: { id: from_id } } }
        client.send_message(chat_id: chat_id, text: 'Дзякуй. Вам хутка напішуць, каб спытаць падрабязней')
        client.send_message(chat_id: ADMIN_ID, text: "Ад: [author](tg://user?id=#{from_id}). #{message}.")
      end
    rescue StandardError => e
      client.send_message(chat_id: ADMIN_ID, text: e.message + " params: #{params}", parse_mode: 'HTML')

      raise
    end

    private

    def send_main_menu(chat_id)
      client.send_message(
        chat_id: chat_id,
        text: 'Што адбылося?',
        reply_markup: {
          keyboard: [
            [{ text: 'Затрыманне' }],
            [{ text: 'Пратакол' }],
            [{ text: 'Суд' }],
            [{ text: 'Ператрус' }],
            [{ text: 'Позва' }]
          ],
          resize_keyboard: true
        }
      )
    end

    def client
      @client ||= ::Telegram::ClientService.new(tg_token: ENV['REPRESSIONS_TOKEN'])
    end
  end
end
