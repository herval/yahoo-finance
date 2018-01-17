# IMPORTANT: Yahoo Finance CSV API is no longer operational - this Gem is currently not working until support to the v7 API is added 

[![Build Status](https://travis-ci.org/herval/yahoo-finance.svg?branch=master)](https://travis-ci.org/herval/yahoo-finance)

# Ruby's Yahoo Finance Wrapper
A dead simple wrapper for yahoo finance quotes end-point.

## Installation:

Just add it to your `Gemfile`: 

`gem 'yahoo-finance'`


## Usage:

### Getting latest quotes for a set of symbols

Pass an array of valid symbols (stock names, indexes, exchange rates):

```ruby
yahoo_client = YahooFinance::Client.new
data = yahoo_client.quotes(["BVSP", "NATU3.SA", "USDJPY=X"])
```

Data is now an array of results. You now have accessor methods to retrieve the data, with the return results being strings:

```ruby
puts data[0].symbol + " value is: " + data[0].ask 
```
Passing `na_as_nil: true` will convert "N/A" responses to `nil`

```ruby
yahoo_client = YahooFinance::Client.new
data = yahoo_client.quotes(["BVSP"])
data[0].ask
> "N/A"

data = yahoo_client.quotes(["BVSP"], { na_as_nil: true } )
data[0].ask
> nil
```

The full list of fields with values follows:

```ruby
  language                          = "en-US"
  quoteType                         = "EQUITY"
  quoteSourceName                   = "Nasdaq Real Time Price"
  currency                          = "USD"
  esgPopulated                      = false
  tradeable                         = true
  bid                               = 175.82
  ask                               = 175.84
  bidSize                           = 1
  askSize                           = 10
  messageBoardId                    = "finmb_24937"
  fullExchangeName                  = "NasdaqGS"
  longName                          = "Apple Inc."
  financialCurrency                 = "USD"
  averageDailyVolume3Month          = 26971341
  averageDailyVolume10Day           = 22001080
  fiftyTwoWeekLowChange             = 57.97
  fiftyTwoWeekLowChangePercent      = 0.49035698
  fiftyTwoWeekHighChange            = -3.199997
  fiftyTwoWeekHighChangePercent     = -0.017838212
  fiftyTwoWeekLow                   = 118.22
  fiftyTwoWeekHigh                  = 179.39
  dividendDate                      = 1510790400
  earningsTimestamp                 = 1517518800
  earningsTimestampStart            = 1517259600
  earningsTimestampEnd              = 1517605200
  trailingAnnualDividendRate        = 2.4
  trailingPE                        = 19.130293
  exchangeDataDelayedBy             = 0
  trailingAnnualDividendYield       = 0.013692379
  epsTrailingTwelveMonths           = 9.21
  epsForward                        = 12.22
  sharesOutstanding                 = 5087059968
  bookValue                         = 26.149
  fiftyDayAverage                   = 172.5509
  fiftyDayAverageChange             = 3.6390991
  fiftyDayAverageChangePercent      = 0.021090003
  twoHundredDayAverage              = 161.8961
  twoHundredDayAverageChange        = 14.2939
  twoHundredDayAverageChangePercent = 0.08829057
  marketCap                         = 896289079296
  forwardPE                         = 14.418167
  priceToBook                       = 6.737925
  sourceInterval                    = 15
  exchangeTimezoneName              = "America/New_York"
  exchangeTimezoneShortName         = "EST"
  gmtOffSetMilliseconds             = -18000000
  regularMarketPrice                = 176.19
  regularMarketTime                 = 1516136401
  regularMarketChange               = -0.8999939
  regularMarketOpen                 = 177.9
  regularMarketDayHigh              = 179.39
  regularMarketDayLow               = 176.14
  regularMarketVolume               = 25789935
  market                            = "us_market"
  exchange                          = "NMS"
  shortName                         = "Apple Inc."
  priceHint                         = 2
  postMarketChangePercent           = -0.23837797
  postMarketTime                    = 1516146013
  postMarketPrice                   = 175.77
  postMarketChange                  = -0.41999817
  regularMarketChangePercent        = -0.50821275
  regularMarketPreviousClose        = 175.28
  marketState                       = "POST"
  symbol                            = "AAPL"
```

### Stock Suggestion by query

Create a YahooFinance::Client instance

```ruby
yahoo_client = YahooFinance::Client.new
yahoo_client.query('Apple') 
```
This method returns an array of quotes based on the entered query. 

*For backwards compatibility this can also be called using yahoo_client.symbols(query)

### Getting symbols by stock market (beta)

Create a YahooFinance::Client instance

```ruby
yahoo_client = YahooFinance::Client.new
```

Calling symbols_by_market method (symbols_by_market(country, stock_market))

Note: Can only be called with US Stock Markets for now. 

*Important: This data comes directly from NASDAQ's CSV endpoints, NOT Yahoo Finance*. It might be extracted into a different Gem in the future.

```ruby
yahoo_client.symbols_by_market('us', 'nyse') # Only US Stock Markets For Now
```

This method returns an array of symbols that can be used with the quotes method

```ruby
data = yahoo_client.quotes(yahoo_client.symbols_by_market('us', 'nyse'), [:ask, :bid, :last_trade_date])
```

### Getting companies by stock market (beta)

Create a YahooFinance::Client instance

```ruby
yahoo_client = YahooFinance::Client.new
```

Calling `companies_by_market` method (`companies_by_market(country, stock_market)`)

Note: Can only be called with US Stock Markets for now.

*Important: This data comes directly from NASDAQ's CSV endpoints, NOT Yahoo Finance*. It might be extracted into a different Gem in the future.

```ruby
 # Only US Stock Markets For Now
yahoo_client.companies_by_market('us', 'nyse')
yahoo_client.companies_by_market('us', ['nyse', 'nasdaq'])
yahoo_client.companies_by_market('us') #All available markets by default
```

This method returns an hash of companies grouped by market.
Each company object contains the following fields: symbol, name, last_sale, market_cap, ipo_year, sector, industry, summary_quote, market

### Getting sectors (beta)

Create a YahooFinance::Client instance

```ruby
yahoo_client = YahooFinance::Client.new
```

Calling `sectors` method (`sectors(country, stock_market)`)

Note: Can only be called with US Stock Markets for now.

*Important: This data comes directly from NASDAQ's CSV endpoints, NOT Yahoo Finance*. It might be extracted into a different Gem in the future.

```ruby
 # Only US Stock Markets For Now
yahoo_client.sectors('us', 'nyse')
yahoo_client.sectors('us', ['nyse', 'nasdaq'])
yahoo_client.sectors('us') #All available markets by default
```

This method returns an array of sectors on the selected markets.
Each sector object contains the following fields: name

### Getting industries (beta)

Create a YahooFinance::Client instance

```ruby
yahoo_client = YahooFinance::Client.new
```

Calling `industries` method (`industries(country, stock_market)`)

Note: Can only be called with US Stock Markets for now.

*Important: This data comes directly from NASDAQ's CSV endpoints, NOT Yahoo Finance*. It might be extracted into a different Gem in the future.

```ruby
 # Only US Stock Markets For Now
yahoo_client.industries('us', 'nyse')
yahoo_client.industries('us', ['nyse', 'nasdaq'])
yahoo_client.industries('us') #All available markets by default
```

This method returns an array of industries on the selected markets.
Each industry object contains the following fields: name, sector

### Getting historical quotes

Retrieve historical data for a specific symbol (i.e. `AAPL`).

The last parameter (options) can include:
- `period`: can be specified as `:daily`, `:monthly`, `:weekly`
- `start_date`: the date from which historical quotes should be fetched (the parameter value should respond to `to_time`) (default: yesterday)
- `end_date`: the date up to which historical quotes should be fetched (the parameter value should respond to `to_time`) (default: today)

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
data = yahoo_client.historical_quotes("AAPL", { period: :monthly })
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
