#!/usr/bin/ruby

# yahoo_finance_test.rb
# August 5, 2007
#

require 'test/unit'
require File.join(File.dirname(__FILE__),'../lib/yahoo_finance')

class TestYahoo_finance_test < Test::Unit::TestCase
#  def setup
#  end
#
#  def teardown
#  end

  def test_quotes

    quotes = YahooFinance.quotes(["BVSP", "AAPL"])
    assert_equal(2, quotes.size)
    
    assert_nothing_raised do
      q = YahooFinance.historical_quotes("MSFT", Time::now-(24*60*60*40), Time::now, { :raw => false, :period => :daily })
      [:trade_date, :open, :high, :low, :close, :volume, :adjusted_close].each do |col|
        assert q.first.send(col)
      end
    end

    assert_nothing_raised do
     q = YahooFinance.historical_quotes("MSFT", Time::now-(24*60*60*400), Time::now, { :raw => false, :period => :dividends_only })
     assert q.first.dividend_pay_date
     assert q.first.dividend_yield
    end
     
    assert_nothing_raised do
     q = YahooFinance.quotes(["AAPL", "MSFT", "BVSP", "JPYUSD" ], YahooFinance::COLUMNS.keys.collect{ |c| YahooFinance::COLUMNS[c][1] == :undefined ? c : nil }.compact[0..20], { :raw => false })
     #q.each { |q1| p q1 }
    end
  end

  def test_escapes_symbol_for_url
    assert_nothing_raised do
      YahooFinance.quotes(["^AXJO"])
    end
    assert_nothing_raised do
      YahooFinance.historical_quotes("^AXJO", Time::now-(24*60*60*400), Time::now)
    end
  end
  
  def test_recognizes_csv_strings
    quotes = YahooFinance.quotes(["GOOG"], [:name])
    assert_no_match /^\"/, quotes.first.name
  end
    
end
