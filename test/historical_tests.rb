require 'test_helper'

class YahooFinance::HistoricalTest < MiniTest::Test 
  def days_ago(days)
    Time.now-(24*60*60*days)
  end

  def test_historical_quotes
    ycl = YahooFinance::Client.new
    q = ycl.historical_quotes('MSFT', period: :daily, start_date: days_ago(40))

    [:trade_date, :open, :high, :low, :close, :volume, :adjusted_close].each do |col|
      assert q.first.public_send(col)
    end
  end

  def test_escapes_symbol_for_url
    ycl = YahooFinance::Client.new
    quote = ycl.historical_quotes('^AXJO', start_date: days_ago(400))
    assert_equal(1, quote)
  end

  def test_dividends
    skip
    # I don't see how this was ever working??
    
    ycl = YahooFinance::Client.new
    valid periods are :daily, :weekly, monthly
    
    q = ycl.historical_quotes('MSFT', raw: false, period: :dividends_only, start_date: days_ago(400))
    assert q.first.dividend_pay_date
    assert q.first.dividend_yield
  end
end
