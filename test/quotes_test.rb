require 'test_helper'

# Yahoo Finance Tests
class YahooFinance::QuotesTest < MiniTest::Test 

  def test_simple_quotes
    ycl = YahooFinance::Client.new
    quotes = ycl.quotes(['^BVSP', 'AAPL'])
    assert_equal(2, quotes.size)
  end

  def test_quote
    ycl = YahooFinance::Client.new
    quote = ycl.quote('AAPL')
    assert !quote.symbol.nil?, ':symbol name is always present'
  end

  def test_invalid_symbol_name
    ycl = YahooFinance::Client.new
    quotes = ycl.quotes(['AaaAPLLL'])
    assert_equal(0, quotes.size)
  end

  def test_escapes_symbol_for_url
    ycl = YahooFinance::Client.new
    quote = ycl.quotes(['^AXJO'])
    assert_equal(1, quote.size)
  end

  def test_na_as_nil
    skip
    # Skipping unil we can find a symbol that returns N/A
    # since now we don't return an object if the quote is nil
    #
    ycl = YahooFinance::Client.new
    quotes = ycl.quotes(['non_exisiting_symbol'])
    assert_equal('N/A', quotes.first.name)
    assert_equal('N/A', quotes.first.notes)
    quotes = ycl.quotes(['non_exisiting_symbol'], na_as_nil: true)
    assert_equal(nil, quotes.first.name)
    assert_equal(nil, quotes.first.notes)
  end
end
