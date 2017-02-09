#!/usr/bin/ruby
require 'test/unit'
require File.join(File.dirname(__FILE__), '../lib/yahoo-finance')

# Yahoo Finance Tests
class YahooFinanceTest < Test::Unit::TestCase
  def days_ago(days)
    Time.now-(24*60*60*days)
  end

  def test_finance_utils_markets
    assert_not_equal(nil, YahooFinance::FinanceUtils::MARKETS.us)
    assert_not_equal(nil, YahooFinance::FinanceUtils::MARKETS.us.nyse.url)
    assert_not_equal(nil, YahooFinance::FinanceUtils::MARKETS.us.nasdaq.url)
  end

  def test_finance_utils_stock_by_market
    ycl = YahooFinance::Client.new
    assert 0 < ycl.symbols_by_market('us', 'nyse').count
    assert 0 < ycl.symbols_by_market('us', 'nasdaq').count
  end

  def test_quote
    columns = [:open, :high, :low, :close, :volume, :last_trade_price]
    ycl = YahooFinance::Client.new
    quote = ycl.quote('AAPL', columns)
    columns.each do |col|
      assert quote.send(col), 'quote.#{col} was nil #{quote}'
    end
    assert !quote.symbol.nil?, ':symbol name is always present'
  end

  def test_simple_quotes
    ycl = YahooFinance::Client.new
    quotes = ycl.quotes(['BVSP', 'AAPL'])
    assert_equal(2, quotes.size)
  end

  def test_not_found
    ycl = YahooFinance::Client.new
    quotes = ycl.quotes(['AaaAPLLL'])
    # not found symbols are still returned
    assert_equal(1, quotes.size)
  end

  def test_custom_columns
    ycl = YahooFinance::Client.new
    q = ycl.quotes(['AAPL'], YahooFinance::Client::COLUMNS.map { |k, v| k }, { raw: false })[0]
    q.each_pair do |k, v|
      type = YahooFinance::Client::COLUMNS[k][1]
      assert v.is_a?(type), "conversion failed: #{k} - #{v} (#{v.class.to_s} should be #{type.to_s})" if !v.nil?
    end
  end

  def test_historical_quotes
    ycl = YahooFinance::Client.new
    q = ycl.historical_quotes('MSFT', raw: false, period: :daily, start_date: days_ago(40))
    
    [:trade_date, :open, :high, :low, :close, :volume, :adjusted_close].each do |col|
      assert q.first.send(col)
    end
  end

  def test_splits
    ycl = YahooFinance::Client.new
    s = ycl.splits('AAPL')
    assert s.first.date
    assert s.first.before
    assert s.first.after
  end

  def test_dividends
    ycl = YahooFinance::Client.new
    q = ycl.historical_quotes('MSFT', raw: false, period: :dividends_only, start_date: days_ago(400))
    assert q.first.dividend_pay_date
    assert q.first.dividend_yield
  end

  def test_escapes_symbol_for_url
    ycl = YahooFinance::Client.new
    assert_nothing_raised do
      ycl.quotes(['^AXJO'])
    end
    assert_nothing_raised do
      ycl.historical_quotes('^AXJO', start_date: days_ago(400))
    end
  end

  def test_recognizes_csv_strings
    ycl = YahooFinance::Client.new
    quotes = ycl.quotes(['GOOG'], [:name])
    assert_no_match /^\'/, quotes.first.name
  end

  def test_symbols
    ycl = YahooFinance::Client.new
    symbols = ycl.symbols('yahoo')
    assert_equal(10, symbols.size)

    assert_nothing_raised do
      symbols.first.symbol
      symbols.first.name
    end
  end

  def test_na_as_nil
    ycl = YahooFinance::Client.new
    quotes = ycl.quotes(['non_exisiting_symbol'], [:name, :notes])
    assert_equal('N/A', quotes.first.name)
    assert_equal('N/A', quotes.first.notes)
    quotes = ycl.quotes(['non_exisiting_symbol'], [:name, :notes], na_as_nil: true)
    assert_equal(nil, quotes.first.name)
    assert_equal(nil, quotes.first.notes)
  end
end
