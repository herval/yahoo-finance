require 'csv'

module YahooFinance
  # Provides information on stock splits
  #
  # @todo Currently Broken due to to ichart.finance.yahoo.com endpoint going down
  module Splits

    def splits(symbol, options = {})
      rows = read_splits(symbol, options).select { |row| row[0] == "SPLIT" }
      rows.map do |type, date, value|
        after, before = value.split(":")
        OpenStruct.new(symbol: symbol, date: Date.strptime(date.strip, "%Y%m%d"), before: before.to_i, after: after.to_i)
      end
    end

    private 

    def read_splits(symbol, options)
      params = { s: URI.escape(symbol), g: "v" }
      if options[:start_date]
        params[:a] = options[:start_date].month-1
        params[:b] = options[:start_date].day
        params[:c] = options[:start_date].year
      end
      if options[:end_date]
        params[:d] = options[:end_date].month-1
        params[:e] = options[:end_date].day
        params[:f] = options[:end_date].year
      end

      url = "https://ichart.finance.yahoo.com/x?#{params.map{|k, v| "#{k}=#{v}"}.join("&")}"
      conn = open(url)
      CSV.parse(conn.read)
    end

  end
end
