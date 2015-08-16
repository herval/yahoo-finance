# Ruby's Yahoo Finance Wrapper
A dead simple wrapper for yahoo finance quotes end-point.

## Installation:

`gem install 'yahoo-finance'`
`require 'yahoo-finance'`

If using bundler: 

`gem 'yahoo-finance', git: 'https://github.com/herval/yahoo-finance.git'`

`require: 'yahoo-finance'`

## Usage:

### Getting latest quotes for a set of symbols

Pass an array of valid symbols (stock names, indexes, exchange rates) and a list of fields you want:

```ruby
yahoo_client = YahooFinance::Client.new
data = yahoo_client.quotes(["BVSP", "NATU3.SA", "USDJPY=X"], [:ask, :bid, :last_trade_date])
```

Data is now an array of results. You now have accessor methods to retrieve the data, with the return results being strings:

```ruby
puts data[0].symbol + " value is: " + data[0].ask 
```

Passing `raw: false` will return numerical values

```ruby
yahoo_client = YahooFinance::Client.new
data = yahoo_client.quotes(["BVSP", "NATU3.SA", "USDJPY=X"], [:ask, :bid, :last_trade_date], { raw: false } )
data[0].ask # This is now a float
```

The full list of fields follows:

``` ruby
     :after_hours_change_real_time
     :annualized_gain 
     :ask
     :ask_real_time
     :ask_size
     :average_daily_volume
     :bid
     :bid_real_time
     :bid_size
     :book_value
     :change
     :change_and_percent_change
     :change_from_200_day_moving_average 
     :change_from_50_day_moving_average 
     :change_from_52_week_high 
     :change_From_52_week_low 
     :change_in_percent 
     :change_percent_realtime 
     :change_real_time
     :close 
     :comission
     :day_value_change 
     :day_value_change_realtime 
     :days_range
     :days_range_realtime 
     :dividend_pay_date 
     :dividend_per_share
     :dividend_yield
     :earnings_per_share
     :ebitda 
     :eps_estimate_current_year 
     :eps_estimate_next_quarter 
     :eps_estimate_next_year 
     :error_indicator 
     :ex_dividend_date
     :float_shares 
     :high 
     :high_52_weeks 
     :high_limit 
     :holdings_gain 
     :holdings_gain_percent 
     :holdings_gain_percent_realtime 
     :holdings_gain_realtime 
     :holdings_value 
     :holdings_value_realtime 
     :last_trade_date
     :last_trade_price
     :last_trade_realtime_withtime 
     :last_trade_size 
     :last_trade_time 
     :last_trade_with_time 
     :low 
     :low_52_weeks 
     :low_limit 
     :market_cap_realtime 
     :market_capitalization 
     :more_info 
     :moving_average_200_day 
     :moving_average_50_day 
     :name 
     :notes 
     :one_year_target_price 
     :open 
     :order_book 
     :pe_ratio 
     :pe_ratio_realtime 
     :peg_ratio 
     :percent_change_from_200_day_moving_average 
     :percent_change_from_50_day_moving_average 
     :percent_change_from_52_week_high 
     :percent_change_from_52_week_low 
     :previous_close 
     :price_eps_estimate_current_year 
     :price_eps_Estimate_next_year 
     :price_paid 
     :price_per_book 
     :price_per_sales 
     :shares_owned 
     :short_ratio 
     :stock_exchange 
     :symbol 
     :ticker_trend 
     :trade_date
     :trade_links 
     :volume
     :weeks_range_52 
```

### Getting symbols by stock market (beta)

Create a YahooFinance::Client instance

```ruby
yahoo_client = YahooClient::Client.new
```

Calling symbols_by_market method (symbols_by_market(country, stock_market))

Note: Can only be called with US Stock Markets for now. 

*Important: This data comes directly from NASDAQ's CSV endpoints, NOT Yahoo Finance*. It might be extracted into a different Gem in the future.

```ruby
yahoo_client.symbols_by('us', 'nyse') # Only US Stock Markets For Now
```

This method returns an array of symbols that can be used with the quotes method

```ruby
data = yahoo_client.quotes(yahoo_client.symbols_by_market('us', 'nyse'), [:ask, :bid, :last_trade_date])
```

### Getting historical quotes

Here you can specify a date range and a symbol, and retrieve historical data for it. 
The last parameter (options) can include, besides the "raw" option, a "period" option.
The period can be specified as :daily, :monthly, :weekly or :dividends_only

```ruby
yahoo_client = YahooFinance::Client.new
data = yahoo_client.historical_quotes("AAPL") # entire historical data
```

or

```ruby
yahoo_client = YahooFinance::Client.new
data = yahoo_client.historical_quotes("AAPL", { start_date: Time::now-(24*60*60*10), end_date: Time::now }) # 10 days worth of data
```

or

``` ruby
yahoo_client = YahooFinance::Client.new
data = yahoo_client.historical_quotes("AAPL", { raw: false, period: :monthly })
```

### Getting splits

You can also retrieve split data.

```ruby
yahoo_client = YahooFinance::Client.new
data = yahoo_client.splits('AAPL', :start_date => Date.today - 10*365)
data[0].date   # Date<2014-06-09>
data[0].before # 1
data[0].after  # 7
```


Enjoy! :-)

- Herval (hervalfreire@gmail.com)
- Eric D. Santos Sosa (eric.santos@cometa.works)
