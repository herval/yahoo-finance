require 'test_helper'

class YahooFinance::SplitsTest < MiniTest::Test 

  def test_splits
    skip
    # Need to get Splits working with a new API endpoint
    ycl = YahooFinance::Client.new
    s = ycl.splits('AAPL')
    assert s.first.date
    assert s.first.before
    assert s.first.after
  end

end
