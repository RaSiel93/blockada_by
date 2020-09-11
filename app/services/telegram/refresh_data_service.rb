# frozen_string_literal: true

module Telegram
  class RefreshDataService < BaseService
    DOWNLOAD_LINK_PATTERN = 'https://spreadsheets.google.com/feeds/download/spreadsheets/Export?key=%<id>s&exportFormat=xlsx'
    APP_LINK = 'https://blacklist2020.netlify.app/'

    def self.call
      new.call
    end

    def call
      download_link = format(DOWNLOAD_LINK_PATTERN, id: ENV.fetch('DOC_ID'))

      conn = Faraday.new do |faraday|
        faraday.use FaradayMiddleware::FollowRedirects
        faraday.adapter Faraday.default_adapter
      end

      response = conn.get(download_link)

      tf = Tempfile.new('blacklist.xlsx', encoding: 'ascii-8bit')
      tf.write(response.body)

      spreadsheet = SimpleXlsxReader.open(tf.path)

      tf.unlink

      process_sheet(spreadsheet.sheets.first)
      process_sheet(spreadsheet.sheets.third) do |brand, row|
        brand.bad = false
        brand.why_removed = row[4]
      end
    end

    private

    def process_sheet(sheet)
      sheet.rows[1..].each do |row|
        next unless row[1] && row[0]

        category = Category.find_or_create_by(name: row[1])
        brand = category.brands.find_or_initialize_by(name: row[0])
        brand.description = row[2]
        brand.logo = prepare_logo_link(row[3])

        yield(brand, row) if block_given?

        brand.save
      end
    end

    def prepare_logo_link(link)
      return if link.blank?
      return link if link.match(/http/)

      APP_LINK + link
    end
  end
end
