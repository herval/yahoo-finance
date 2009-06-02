# yahoo_finance_test.rb
# August 5, 2007
#

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'

class TestYahoo_finance_test < Test::Unit::TestCase
#  def setup
#  end
#
#  def teardown
#  end

  def test_quotes

    quotes = YahooFinance.quotes(["BVSP", "AAPL"])
    assert_equal(2, quotes.size)
    
    

 q = YahooFinance.historical_quotes("MSFT", Time::now-(24*60*60*40), Time::now, { :raw => false, :period => :daily })
 q.each { |q1| p q1 }
 
 q = YahooFinance.historical_quotes("MSFT", Time::now-(24*60*60*400), Time::now, { :raw => false, :period => :dividends_only })
 q.each { |q1| p q1 }
 
 q = YahooFinance.quotes(["AAPL", "MSFT", "BVSP", "JPYUSD" ], YahooFinance::COLUMNS.keys.collect{ |c| YahooFinance::COLUMNS[c][1] == :undefined ? c : nil }.compact[0..20], { :raw => false })
 q.each { |q1| p q1 }
    
    # assert_equal("foo", bar)

    # assert, assert_block, assert_equal, assert_in_delta, assert_instance_of,
    # assert_kind_of, assert_match, assert_nil, assert_no_match, assert_not_equal,
    # assert_not_nil, assert_not_same, assert_nothing_raised, assert_nothing_thrown,
    # assert_operator, assert_raise, assert_raises, assert_respond_to, assert_same,
    # assert_send, assert_throws

  end
end
