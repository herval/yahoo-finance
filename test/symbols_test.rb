require 'test_helper'

class YahooFinance::SymbolsTest < MiniTest::Test 

  def test_symbols
    ycl = YahooFinance::Client.new
    symbols = ycl.symbols('yahoo')
    assert_equal(10, symbols.size)
    refute_nil symbols.first.symbol
    refute_nil symbols.first.name
  end

end
