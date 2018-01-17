require 'test_helper'

class YahooFinance::SymbolsTest < MiniTest::Test 

  def test_symbols
    ycl = YahooFinance::Client.new
    symbols = ycl.symbols('yahoo')
    assert_equal(10, symbols.size)
    refute_nil symbols.first.symbol
    refute_nil symbols.first.name
  end

  def test_symbols_using_real_stock_apple
    ycl = YahooFinance::Client.new
    symbols = ycl.symbols('apple')
    assert_equal(10, symbols.size)
    assert_equal "AAPL",  symbols.first.symbol
    assert_equal "Apple Inc.", symbols.first.name
  end

  def test_symbols_is_aliased_as_query
    ycl = YahooFinance::Client.new
    symbols = ycl.query('apple')
    assert_equal(10, symbols.size)
    assert_equal "AAPL",  symbols.first.symbol
    assert_equal "Apple Inc.", symbols.first.name
  end

  

end
