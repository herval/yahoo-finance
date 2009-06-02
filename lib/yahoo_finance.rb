require 'open-uri'
require 'ostruct'

 class YahooFinance
  
   VERSION = '0.0.2'

   COLUMNS = {
     :ask => ["a", :float],
     :average_daily_volume => ["a2", :float],
     :ask_size => ["a5", :integer],
     :bid => ["b", :float],
     :ask_real_time => ["b2", :time],
     :bid_real_time => ["b3", :float],
     :book_value => ["b4", :float],
     :bid_size => ["b6", :integer],
     :chance_and_percent_change => ["c", :string],
     :change => ["c1", :float],
     :comission => ["c3", :undefined],
     :change_real_time => ["c6", :float],
     :after_hours_change_real_time => ["c8", :undefined],
     :dividend_per_share => ["d", :float],
     :last_trade_date => ["d1", :date],
     :trade_date => ["d2", :undefined],
     :earnings_per_share => ["e", :float],
     :error_indicator => ["e1", :string],
     :eps_estimate_current_year => ["e7", :float],
     :eps_estimate_next_year => ["e8", :float],
     :eps_estimate_next_quarter => ["e9", :float],
     :float_shares => ["f6", :float],
     :low => ["g", :float],
     :high => ["h", :float],
     :low_52_weeks => ["j", :float],
     :high_52_weeks => ["k", :float],
     :holdings_gain_percent => ["g1", :float],
     :annualized_gain => ["g3", :float],
     :holdings_gain => ["g4", :float],
     :holdings_gain_percent_realtime => ["g5", :float],
     :holdings_gain_realtime => ["g6", :float],
     :more_info => ["i", :string],
     :order_book => ["i5", :float],
     :market_capitalization => ["j1", :currency_amount],
     :market_cap_realtime => ["j3", :currency_amount],
     :ebitda => ["j4", :currency_amount],
     :change_From_52_week_low => ["j5", :float],
     :percent_change_from_52_week_low => ["j6", :float],
     :last_trade_realtime_withtime => ["k1", :string],
     :change_percent_realtime => ["k2", :string],
     :last_trade_size => ["k3", :integer],
     :change_from_52_week_high => ["k4", :float],
     :percent_change_from_52_week_high => ["k5", :float],
     :last_trade_with_time => ["l", :string],
     :last_trade_price => ["l1", :float],
     :close => ["l1", :float], # same as :last_trade_price
     :high_limit => ["l2", :float],
     :low_limit => ["l3", :float],
     :days_range => ["m", :float],
     :days_range_realtime => ["m2", :float],
     :moving_average_50_day => ["m3", :float],
     :moving_average_200_day => ["m4", :float],
     :change_from_200_day_moving_average => ["m5", :float],
     :percent_change_from_200_day_moving_average => ["m6", :float],
     :change_from_50_day_moving_average => ["m7", :float],
     :percent_change_from_50_day_moving_average => ["m8", :float],
     :name => ["n", :string],
     :notes => ["n4", :string],
     :open => ["o", :float],
     :previous_close => ["p", :float],
     :price_paid => ["p1", :float],
     :change_in_percent => ["p2", :float],
     :price_per_sales => ["p5", :float],
     :price_per_book => ["p6", :float],
     :ex_dividend_date => ["q", :date],
     :pe_ratio => ["p5", :float],
     :dividend_pay_date => ["r1", :undefined],
     :pe_ratio_realtime => ["r2", :float],
     :peg_ratio => ["r5", :float],
     :price_eps_estimate_current_year => ["r6", :float],
     :price_eps_Estimate_next_year => ["r7", :float],
     :symbol => ["s", :string],
     :shares_owned => ["s1", :float],
     :short_ratio => ["s7", :float],
     :last_trade_time => ["t1", :time],
     :trade_links => ["t6", :string],
     :ticker_trend => ["t7", :string],
     :one_year_target_price => ["t8", :float],
     :volume => ["v", :float],
     :holdings_value => ["v1", :undefined],
     :holdings_value_realtime => ["v7", :undefined],
     :weeks_range_52 => ["w", :float],
     :day_value_change => ["w1", :float],
     :day_value_change_realtime => ["w4", :string],
     :stock_exchange => ["x", :string],
     :dividend_yield => ["y", :float],
     :adjusted_close => [nil, :float] # this one only comes in historical quotes
  }
  
  HISTORICAL_MODES = {
    :daily => "d",
    :weekly => "w",
    :monthly => "m",
    :dividends_only => "v"
  }

  ROWS_PER_REQUEST = 50

  # retrieve the quote data (an OpenStruct per quote)
  # the options param can be used to specify the following attributes:
  # :raw - if true, each column will be converted (to numbers, dates, etc)
  def self.quotes(symbols_array, columns_array = [:symbol, :last_trade_price, :last_trade_date, :change, :previous_close], options = { :raw => true })
     ret = []
     cols = columns_array.collect { |c| COLUMNS[c][0] }.join
     types = columns_array.collect { |c| COLUMNS[c][1] }.join if options[:raw]

     i = 0
     k = 0
     while i < symbols_array.size
       subset = symbols_array[i..i+ROWS_PER_REQUEST]
       symb_str = subset.collect { |s| "#{s}" }.join("+")

       lines = read_lines(symb_str, cols)
       for line in lines
         ret << extract_data(line, symbols_array[k], columns_array, options)
         k+=1
       end

       i += ROWS_PER_REQUEST+1
     end

     return ret
  end
  
  def self.historical_quotes(symbol, start_date, end_date, options = { :raw => true, :period => :daily })
     options[:period] ||= :daily
     lines = read_historical(symbol, start_date, end_date, options)
     ret = []
     
     if options[:period] == :dividends_only
       cols = [:dividend_pay_date, :dividend_yield]
     else
       cols = [:trade_date, :open, :high, :low, :close, :volume, :adjusted_close]
     end
     
     for line in lines
         ret << extract_data(line, symbol, cols, options)        
     end
     
     return ret
  end
  
  private
  
  def self.extract_data(raw_line, symbol, columns_array, options)
     datamap = {}
     datamap[:symbol] = symbol
     data = raw_line.split(',')

     for j in (0..data.size-1)
       if !options[:raw]
         datamap[columns_array[j]] = format(data[j], COLUMNS[columns_array[j]][1])
       else
         datamap[columns_array[j]] = data[j]
       end
     end

     OpenStruct.new(datamap)
  end
  
  def self.format(str, type)
    case type
      when :float then str.to_f
      when :integer then str.to_i
      #when :date then DateTime::parse(str)
      #when :time then Time.parse(str)
    else str
    end
  end
  
  def self.read_lines(symb_str, cols)
     conn = open("http://finance.yahoo.com/d/quotes.csv?s=#{symb_str}&f=#{cols}")
     lines = conn.read
     
     lines.split("\r\n")
  end
  
  def self.read_historical(symbol, start_date, end_date, options)
     url = "http://ichart.finance.yahoo.com/table.csv?s=#{symbol}&d=#{end_date.month-1}&e=#{end_date.day}&f=#{end_date.year}&g=#{HISTORICAL_MODES[options[:period]]}&a=#{start_date.month-1}&b=#{start_date.day}&c=#{start_date.year}&ignore=.csv"
     begin
       conn = open(url) 
     rescue
       return []
     end
     lines = conn.read

     all_lines = lines.split("\n")
     return all_lines[1..all_lines.size-1]
  end
  
 end