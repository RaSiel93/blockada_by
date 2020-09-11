# frozen_string_literal: true

module Telegram
  class ResolveWebhookService < BaseService
    MAX_LENGTH = 4096
    SEARCH_QUERY = <<~SQL
      SELECT name, description
      FROM brands
      WHERE bad
      AND (description ILIKE '%<query>s'
                      COLLATE \"ru_RU.UTF-8\"
      OR name ILIKE '%<query>s'
              COLLATE \"ru_RU.UTF-8\")
    SQL

    delegate :t, to: I18n

    def call(params)
      I18n.locale = :ru

      case params
      in { message: { from: { is_bot: true } } }
      in { message: { text: "/start", chat: { id: chat_id } } }
        send_main_menu(chat_id)
      in { message: { text: "#{t("titles.about")}", chat: { id: chat_id } } }
        client.send_message(chat_id: chat_id, text: t("about_1"))
        client.send_message(chat_id: chat_id, text: t("about_2"))
        client.send_message(chat_id: chat_id, text: t("about_3"))
      in { message: { text: "#{t("navigation.back")}", chat: { id: chat_id } } }
        send_main_menu(chat_id)
      in { message: { text: "#{t("titles.categories")}", chat: { id: chat_id } } }
        send_categories(chat_id)
      in { message: { text: "#{t("titles.removed")}", chat: { id: chat_id } } }
        brands = Brand.where(bad: false)
        paragraphs = brands.find_each.map do |brand|
          <<~TEXT
            *#{brand.name}*
            *Почему убрали:* #{brand.why_removed}

          TEXT
        end
        message_blocks = build_message_blocks(paragraphs)

        message_blocks.each do |text|
          client.send_message(chat_id: chat_id, text: text)
        end
      in { message: { text: category, chat: { id: chat_id } } } if category.in?(categories.pluck(:name))
        brands = Category.find_by(name: category).brands.where(bad: true)
        paragraphs = brands.find_each.map do |brand|
          <<~TEXT
            *#{brand.name}*
            *Описание:* #{brand.description}

          TEXT
        end

        message_blocks = build_message_blocks(paragraphs)

        message_blocks.each do |text|
          client.send_message(chat_id: chat_id, text: text)
        end
      in { message: { text: "#{t("categories.other")}", chat: { id: chat_id } } }
        client.send_message(
          chat_id: chat_id,
          text: Spot.where("categories ? 'other'").pluck(:name).join(", ")
        )
      in { message: { text: "#{t("titles.search")}", chat: { id: chat_id } } }
        client.send_message(chat_id: chat_id, text: t("messages.search"))
      in { message: { text: text, chat: { id: chat_id } } } if text.length > 2
        query_brands(text, chat_id)
      in { message: { text: text, chat: { id: chat_id } } } if text.length < 3
        client.send_message(chat_id: chat_id, text: t("errors.text_is_to_short"))
      else
        client.send_message(chat_id: chat_id, text: t('errors.not_supported'))
      end
    end

    private

    def send_main_menu(chat_id)
      client.send_message(
        chat_id: chat_id,
        text: t("hello_and_welcome"),
        reply_markup: {
          keyboard: [
            [{ text: t("titles.search") }],
            [{ text: t("titles.categories") }],
            [{ text: t("titles.removed") }],
            [{ text: t("titles.about") }]
          ],
          resize_keyboard: true
        }
      )
    end

    def send_categories(chat_id)
      client.send_message(
        chat_id: chat_id,
        text: t("titles.categories"),
        reply_markup: {
          keyboard: categories.pluck(:name).map do |category|
            { text: category }
          end.each_slice(2).to_a << [{ text: t("navigation.back") }],
          resize_keyboard: true
        }
      )
    end

    def query_brands(text, chat_id)
      query = format(SEARCH_QUERY, query: "%#{text}%")
      brands = ActiveRecord::Base.connection.execute(query)

      paragraphs = brands.map do |brand|
        <<~TEXT
          *#{brand['name'].gsub(/(#{text})/i, '➡️\1⬅️')}*
          *Описание:* #{brand['description'].gsub(/(#{text})/i, '➡️\1⬅️')}

        TEXT
      end

      message_blocks = build_message_blocks(paragraphs)

      message_blocks.each do |text|
        client.send_message(chat_id: chat_id, text: text)
      end

      client.send_message(chat_id: chat_id, text: t('errors.not_found')) if message_blocks.filter(&:present?).blank?
    end

    def build_message_blocks(paragraphs)
      paragraphs.each_with_object(['']) do |brand, obj|
        if [obj[obj.length - 1].length, obj[obj.length - 1].length + brand.length].max >= MAX_LENGTH
          obj[obj.length] = ''
        end

        obj[obj.length - 1] += brand
      end
    end

    def categories
      @categories ||= Category.all
    end

    def client
      @client ||= Telegram::ClientService.new
    end
  end
end
