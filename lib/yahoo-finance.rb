require "open-uri"
require "ostruct"
require "json"
require "yahoo-finance/version"
require "yahoo-finance/finance-utils"
require "csv"

module YahooFinance
  # Client for Yahoo Finance Queries
  class Client
    include YahooFinance::FinanceUtils

    COLUMNS = {
      ask: "a", average_daily_volume: "a2", ask_size: "a5", bid: "b",
      ask_real_time: "b2", bid_real_time: "b3", book_value: "b4",
      bid_size: "b6", change_and_percent_change: "c", change: "c1",
      comission: "c3", change_real_time: "c6",
      after_hours_change_real_time: "c8", dividend_per_share: "d",
      last_trade_date: "d1", trade_date: "d2", earnings_per_share: "e",
      error_indicator: "e1", eps_estimate_current_year: "e7",
      eps_estimate_next_year: "e8", eps_estimate_next_quarter: "e9",
      float_shares: "f6", low: "g", high: "h", low_52_weeks: "j",
      high_52_weeks: "k", holdings_gain_percent: "g1", annualized_gain: "g3",
      holdings_gain: "g4", holdings_gain_percent_realtime: "g5",
      holdings_gain_realtime: "g6", more_info: "i", order_book: "i5",
      market_capitalization: "j1", market_cap_realtime: "j3", ebitda: "j4",
      change_From_52_week_low: "j5", percent_change_from_52_week_low: "j6",
      last_trade_realtime_withtime: "k1", change_percent_realtime: "k2",
      last_trade_size: "k3", change_from_52_week_high: "k4",
      percent_change_from_52_week_high: "k5", last_trade_with_time: "l",
      last_trade_price: "l1", close: "l1", high_limit: "l2", low_limit: "l3",
      days_range: "m", days_range_realtime: "m2", moving_average_50_day: "m3",
      moving_average_200_day: "m4", change_from_200_day_moving_average: "m5",
      percent_change_from_200_day_moving_average: "m6",
      change_from_50_day_moving_average: "m7",
      percent_change_from_50_day_moving_average: "m8", name: "n", notes: "n4",
      open: "o", previous_close: "p", price_paid: "p1", change_in_percent: "p2",
      price_per_sales: "p5", price_per_book: "p6", ex_dividend_date: "q",
      pe_ratio: "r", dividend_pay_date: "r1", pe_ratio_realtime: "r2",
      peg_ratio: "r5", price_eps_estimate_current_year: "r6",
      price_eps_Estimate_next_year: "r7", symbol: "s", shares_owned: "s1",
      short_ratio: "s7", last_trade_time: "t1", trade_links: "t6",
      ticker_trend: "t7", one_year_target_price: "t8", volume: "v",
      holdings_value: "v1", holdings_value_realtime: "v7", weeks_range_52: "w",
      day_value_change: "w1", day_value_change_realtime: "w4",
      stock_exchange: "x", dividend_yield: "y", adjusted_close: nil
      # only in historical quotes ^
    }

    HISTORICAL_MODES = {
      daily: "d", weekly: "w", monthly: "m", dividends_only: "v"
    }

    SYMBOLS_PER_REQUEST = 50

    # retrieve the quote data (an OpenStruct per quote)
    # the options param can be used to specify the following attributes:
    # :raw - if true, each column will be converted (to numbers, dates, etc)
    def quotes(symbols_array, columns_array = [
      :symbol, :last_trade_price, :last_trade_date,
      :change, :previous_close], options = {})

      options[:raw] ||= true
      ret = []
      symbols_array.each_slice(SYMBOLS_PER_REQUEST) do |symbols|
        read_quotes(symbols.join("+"), columns_array).map do |row|
          ret << OpenStruct.new(row.to_hash)
        end
      end
      ret
    end

    def quote(symbol, columns_array = [
      :symbol, :last_trade_price, :last_trade_date,
      :change, :previous_close], options = {})

      options[:raw] ||= true
      quotes([symbol], columns_array, options).first
    end

    def historical_quotes(symbol, options = {})
      options[:raw] ||= true
      options[:period] ||= :daily
      read_historical(symbol, options).map do |row|
        OpenStruct.new(row.to_hash.merge(symbol: symbol))
      end
    end

    def symbols(query)
      ret = []
      read_symbols(query).each do |row|
        ret << OpenStruct.new(row)
      end
      ret
    end

    def splits(symbol, options = {})
      rows = read_splits(symbol, options).select { |row| row[0] == "SPLIT" }
      rows.map do |row|
        type, date, value = row
        after, before = value.split(":")
        OpenStruct.new(
          symbol: symbol, date: Date.strptime(date.strip, "%Y%m%d"),
          before: before.to_i, after: after.to_i)
      end
    end

    private

    def read_quotes(symb_str, cols)
      columns = "#{cols.map { |col| COLUMNS[col] }.join("")}"
      conn = open("http://download.finance.yahoo.com/d/quotes.csv?s=#{URI.escape(symb_str)}&f=#{columns}")
      CSV.parse(conn.read, headers: cols)
    end

    def read_historical(symbol, options)
      params = {
        s: URI.escape(symbol), g: HISTORICAL_MODES[options[:period]],
        ignore: ".csv" }
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

     url = "http://ichart.finance.yahoo.com/table.csv?#{params.map{|k, v| "#{k}=#{v}"}.join("&")}"
     conn = open(url)
     cols = if options[:period] == :dividends_only
              [:dividend_pay_date, :dividend_yield]
            else
              [:trade_date, :open, :high, :low,
               :close, :volume, :adjusted_close]
            end
     result = CSV.parse(conn.read, headers: cols)
     #:first_row, :header_converters => :symbol)
     result.delete(0)  # drop returned header
     result
    end

    def read_splits(symbol, options)
      params = {
        s: URI.escape(symbol), g: "v" }
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

     url = "http://ichart.finance.yahoo.com/x?#{params.map{|k, v| "#{k}=#{v}"}.join("&")}"
     conn = open(url)
     CSV.parse(conn.read)
    end

    def read_symbols(query)
      conn = open("http://d.yimg.com/autoc.finance.yahoo.com/autoc?query=#{query}&callback=YAHOO.Finance.SymbolSuggest.ssCallback")
      result = conn.read
      result.sub!("YAHOO.Finance.SymbolSuggest.ssCallback(", "").chomp!(")")
      json_result = JSON.parse(result)
      json_result["ResultSet"]["Result"]
    end
  end
end
