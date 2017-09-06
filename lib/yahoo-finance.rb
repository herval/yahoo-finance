require "open-uri"
require 'nokogiri'
require "ostruct"
require "json"
require "yahoo-finance/version"
require "yahoo-finance/finance-utils"
require "csv"
require 'bigdecimal'

module YahooFinance
  # Client for Yahoo Finance Queries
  class Client
    include YahooFinance::FinanceUtils

    COLUMNS = {
      :ask => ["a", BigDecimal],
      :average_daily_volume => ["a2", BigDecimal],
      :ask_size => ["a5", BigDecimal],
      :bid => ["b", BigDecimal],
      :ask_real_time => ["b2", Time],
      :bid_real_time => ["b3", BigDecimal],
      :book_value => ["b4", BigDecimal],
      :bid_size => ["b6", BigDecimal],
      :change_and_percent_change => ["c", String],
      :change => ["c1", BigDecimal],
      :comission => ["c3", String],
      :currency => ["c4", String],
      :change_real_time => ["c6", BigDecimal],
      :after_hours_change_real_time => ["c8", String],
      :dividend_per_share => ["d", BigDecimal],
      :last_trade_date => ["d1", DateTime],
      :trade_date => ["d2", String],
      :earnings_per_share => ["e", BigDecimal],
      :error_indicator => ["e1", String],
      :eps_estimate_current_year => ["e7", BigDecimal],
      :eps_estimate_next_year => ["e8", BigDecimal],
      :eps_estimate_next_quarter => ["e9", BigDecimal],
      :float_shares => ["f6", BigDecimal],
      :low => ["g", BigDecimal],
      :high => ["h", BigDecimal],
      :low_52_weeks => ["j", BigDecimal],
      :high_52_weeks => ["k", BigDecimal],
      :holdings_gain_percent => ["g1", BigDecimal],
      :annualized_gain => ["g3", BigDecimal],
      :holdings_gain => ["g4", BigDecimal],
      :holdings_gain_percent_realtime => ["g5", BigDecimal],
      :holdings_gain_realtime => ["g6", BigDecimal],
      :more_info => ["i", String],
      :order_book => ["i5", BigDecimal],
      :market_capitalization => ["j1", BigDecimal],
      :shares_outstanding => ["j2", BigDecimal],
      :market_cap_realtime => ["j3", BigDecimal],
      :ebitda => ["j4", BigDecimal],
      :change_From_52_week_low => ["j5", BigDecimal],
      :percent_change_from_52_week_low => ["j6", BigDecimal],
      :last_trade_realtime_withtime => ["k1", String],
      :change_percent_realtime => ["k2", String],
      :last_trade_size => ["k3", BigDecimal],
      :change_from_52_week_high => ["k4", BigDecimal],
      :percent_change_from_52_week_high => ["k5", BigDecimal],
      :last_trade_with_time => ["l", String],
      :last_trade_price => ["l1", BigDecimal],
      :close => ["l1", BigDecimal], # same as :last_trade_price
      :high_limit => ["l2", BigDecimal],
      :low_limit => ["l3", BigDecimal],
      :days_range => ["m", BigDecimal],
      :days_range_realtime => ["m2", BigDecimal],
      :moving_average_50_day => ["m3", BigDecimal],
      :moving_average_200_day => ["m4", BigDecimal],
      :change_from_200_day_moving_average => ["m5", BigDecimal],
      :percent_change_from_200_day_moving_average => ["m6", BigDecimal],
      :change_from_50_day_moving_average => ["m7", BigDecimal],
      :percent_change_from_50_day_moving_average => ["m8", BigDecimal],
      :name => ["n", String],
      :notes => ["n4", String],
      :open => ["o", BigDecimal],
      :previous_close => ["p", BigDecimal],
      :price_paid => ["p1", BigDecimal],
      :change_in_percent => ["p2", BigDecimal],
      :price_per_sales => ["p5", BigDecimal],
      :price_per_book => ["p6", BigDecimal],
      :ex_dividend_date => ["q", DateTime],
      :pe_ratio => ["r", BigDecimal],
      :dividend_pay_date => ["r1", String],
      :pe_ratio_realtime => ["r2", BigDecimal],
      :peg_ratio => ["r5", BigDecimal],
      :price_eps_estimate_current_year => ["r6", BigDecimal],
      :price_eps_Estimate_next_year => ["r7", BigDecimal],
      :symbol => ["s", String],
      :shares_owned => ["s1", BigDecimal],
      :revenue => ["s6", BigDecimal],
      :short_ratio => ["s7", BigDecimal],
      :last_trade_time => ["t1", Time],
      :trade_links => ["t6", String],
      :ticker_trend => ["t7", String],
      :one_year_target_price => ["t8", BigDecimal],
      :volume => ["v", BigDecimal],
      :holdings_value => ["v1", String],
      :holdings_value_realtime => ["v7", String],
      :weeks_range_52 => ["w", BigDecimal],
      :day_value_change => ["w1", BigDecimal],
      :day_value_change_realtime => ["w4", String],
      :stock_exchange => ["x", String],
      :dividend_yield => ["y", BigDecimal],
      :adjusted_close => [nil, BigDecimal] # this one only comes in historical quotes
    }

    HISTORICAL_MODES = {
      daily: "1d",
      weekly: "1wk",
      monthly: "1mo"
    }

    SYMBOLS_PER_REQUEST = 50

    # retrieve the quote data (an OpenStruct per quote)
    # the options param can be used to specify the following attributes:
    # :raw - if true, each column will be converted (to numbers, dates, etc)
    def quotes(symbols_array, columns_array = [:symbol, :last_trade_price, :last_trade_date, :change, :previous_close], options = {})
      # remove invalid keys
      columns_array.reject! { |c| !COLUMNS.key?(c) }
      columns_array << :symbol if columns_array.index(:symbol).nil?

      # "N/A" is never present if { raw = false }
      options[:na_as_nil] = true if options[:raw] == false

      ret = []
      symbols_array.each_slice(SYMBOLS_PER_REQUEST) do |symbols|
        read_quotes(symbols.join("+"), columns_array).map do |row|
          data = row.to_hash
          if options[:na_as_nil]
            data.each { |key, value| data[key] = nil if value == 'N/A' }
          end
          if options[:raw] == false
            data.each { |key, value| data[key] = format(value, COLUMNS[key][1]) }
          end
          ret << OpenStruct.new(data)
        end
      end
      ret
    end

    def quote(symbol, columns_array = [:symbol, :last_trade_price, :last_trade_date, :change, :previous_close], options = {})
      options[:raw] ||= true
      quotes([symbol], columns_array, options).first
    end

    def time_from_days(days)
      24*60*60*days
    end

    def historical_quotes(symbol, options = {})
      options[:period] ||= :daily
      start_date = options[:start_date] || Time.now() - time_from_days(1)
      end_date = options[:end_date] || Time.now()
      params = {
        interval: HISTORICAL_MODES[options[:period]],
        filter: 'history'
      }
      days_per_page = case params[:interval]
                 when HISTORICAL_MODES[:daily]
                   140 # 100 results divided by 5 trading days/week * 7 days/week = number of days per results
                 when HISTORICAL_MODES[:weekly]
                   700 # 7days/week * 100 results
                 when HISTORICAL_MODES[:monthly]
                   2900 # for simplicity assume that all months have 29 days * 100 results (remove duplicates at the end)
                 end
      current_date = start_date.to_time.to_i
      data = []
      while Time.at(current_date) < end_date
        params[:period1] = current_date
        current_end_date = [current_date + time_from_days(days_per_page), end_date.to_time.to_i].min
        params[:period2] = current_end_date
        url = "https://finance.yahoo.com/quote/#{URI.escape(symbol)}/history/?#{params.map{|k, v| "#{k}=#{v}"}.join("&")}"
        data << read_historical(symbol, url)
        current_date = current_end_date + time_from_days(1)
      end
      data.uniq.flatten
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
      rows.map do |type, date, value|
        after, before = value.split(":")
        OpenStruct.new(symbol: symbol, date: Date.strptime(date.strip, "%Y%m%d"), before: before.to_i, after: after.to_i)
      end
    end

    def format(str, type)
      if str.nil?
        str
      elsif type == BigDecimal
        BigDecimal.new(str)
      elsif type == DateTime
        DateTime.parse(str)
      elsif type == Time
        Time.parse(str)
      else
        str
      end
    end

    private

    def read_quotes(symb_str, cols)
      columns = "#{cols.map { |col| COLUMNS[col][0] }.join("")}"
      conn = open("https://download.finance.yahoo.com/d/quotes.csv?s=#{URI.escape(symb_str)}&f=#{columns}")
      CSV.parse(conn.read, headers: cols)
    end

    def read_historical(symbol, url)
      doc = Nokogiri::HTML(open(url))
      rows = doc.xpath("//table")[1].css('tr')

      return [] if rows.empty?
      cols = rows[0].css('th').to_a
      trade_date_col = cols.index { |c| c.text == 'Date' }
      open_col = cols.index { |c| c.text == 'Open' }
      high_col = cols.index { |c| c.text == 'High' }
      low_col = cols.index { |c| c.text == 'Low' }
      close_col = cols.index { |c| c.text == 'Close*' }
      adjusted_close_col = cols.index { |c| c.text == 'Adj Close**' }
      volume_col = cols.index { |c| c.text == 'Volume' }

      rows.drop(0).inject([]) do |data, row|
        divs = row.css('td')
        if divs[1] && !divs[1].text.include?('Dividend') && !divs[1].text.include?('Stock Split') #Ignore these rows in the table
          data << OpenStruct.new({
            'symbol': symbol,
            'trade_date': Date.parse(divs[trade_date_col]).to_s,
            'open': divs[open_col].text.to_f,
            'high': divs[high_col].text.to_f,
            'low': divs[low_col].text.to_f,
            'close': divs[close_col].text.to_f,
            'adjusted_close': divs[adjusted_close_col].text.to_f,
            'volume': divs[volume_col].text.gsub(/[^\d^\.]/, '').to_f
          })
        end
        data
      end
    end

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

    def read_symbols(query)
      conn = open("http://d.yimg.com/autoc.finance.yahoo.com/autoc?query=#{query}&region=US&lang=en-US&callback=YAHOO.Finance.SymbolSuggest.ssCallback")
      result = conn.read
      result.sub!("YAHOO.Finance.SymbolSuggest.ssCallback(", "").chomp!(");")
      json_result = JSON.parse(result)
      json_result["ResultSet"]["Result"]
    end
  end
end
