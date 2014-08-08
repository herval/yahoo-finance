# Ruby's Yahoo Finance Wrapper
A dead simple wrapper for yahoo finance quotes end-point.

## Installation:

`gem install 'yahoo-finance'`
`require 'yahoo_finance'`

If using bundler: 
`gem 'yahoo-finance', require: 'yahoo_finance'`

## Usage:

### Getting latest quotes for a set of symbols

Pass an array of valid symbols (stock names, indexes, exchange rates) and a list of fields you want:

```ruby
data = YahooFinance.quotes(["BVSP", "NATU3.SA", "USDJPY=X"], [:ask, :bid, :last_trade_date])
```

Data is now an array of results. You now have accessor methods to retrieve the data, with the return results being strings:

```ruby
puts data[0].symbol + " value is: " + data[0].ask 
```

Passing `raw: false` will return numerical values

```ruby
data = YahooFinance.quotes(["BVSP", "NATU3.SA", "USDJPY=X"], [:ask, :bid, :last_trade_date], { raw: false } )
data[0].ask # This is now a float
```

The full list of fields follows:

``` ruby
     :ask
     :average_daily_volume
     :ask_size
     :bid
     :ask_real_time
     :bid_real_time
     :book_value
     :bid_size
     :change_and_percent_change
     :change
     :comission
     :change_real_time
     :after_hours_change_real_time
     :dividend_per_share
     :last_trade_date
     :trade_date
     :earnings_per_share
     :error_indicator 
     :eps_estimate_current_year 
     :eps_estimate_next_year 
     :eps_estimate_next_quarter 
     :float_shares 
     :low 
     :high 
     :low_52_weeks 
     :high_52_weeks 
     :holdings_gain_percent 
     :annualized_gain 
     :holdings_gain 
     :holdings_gain_percent_realtime 
     :holdings_gain_realtime 
     :more_info 
     :order_book 
     :market_capitalization 
     :market_cap_realtime 
     :ebitda 
     :change_From_52_week_low 
     :percent_change_from_52_week_low 
     :last_trade_realtime_withtime 
     :change_percent_realtime 
     :last_trade_size 
     :change_from_52_week_high 
     :percent_change_from_52_week_high 
     :last_trade_with_time 
     :last_trade_price
     :close 
     :high_limit 
     :low_limit 
     :days_range
     :days_range_realtime 
     :moving_average_50_day 
     :moving_average_200_day 
     :change_from_200_day_moving_average 
     :percent_change_from_200_day_moving_average 
     :change_from_50_day_moving_average 
     :percent_change_from_50_day_moving_average 
     :name 
     :notes 
     :open 
     :previous_close 
     :price_paid 
     :change_in_percent 
     :price_per_sales 
     :price_per_book 
     :ex_dividend_date
     :pe_ratio 
     :dividend_pay_date 
     :pe_ratio_realtime 
     :peg_ratio 
     :price_eps_estimate_current_year 
     :price_eps_Estimate_next_year 
     :symbol 
     :shares_owned 
     :short_ratio 
     :last_trade_time 
     :trade_links 
     :ticker_trend 
     :one_year_target_price 
     :volume
     :holdings_value 
     :holdings_value_realtime 
     :weeks_range_52 
     :day_value_change 
     :day_value_change_realtime 
     :stock_exchange 
     :dividend_yield 
```

### Getting historical quotes

Here you can specify a date range and a symbol, and retrieve historical data for it. 
The last parameter (options) can include, besides the "raw" option, a "period" option.
The period can be specified as :daily, :monthly, :weekly or :dividends_only

```ruby
data = YahooFinance.historical_quotes("BVSP", Time::now-(24*60*60*10), Time::now) # 10 days worth of data
```

or

``` ruby
data = YahooFinance.historical_quotes("BVSP", Time::now-(24*60*60*10), Time::now, { raw: false, period: :monthly })
```

### Getting splits

You can also retrieve split data.

```ruby
data = YahooFinance.splits('AAPL', :start_date => Date.today - 10*365)
data[0].date   # Date<2014-06-09>
data[0].before # 1
data[0].after  # 7
```


Enjoy! :-)

- Herval (hervalfreire@gmail.com)
