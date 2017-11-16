require 'test_helper'

class YahooFinance::FinanceUtilsTest < MiniTest::Test 
  def test_finance_utils_markets
    refute_equal(nil, YahooFinance::FinanceUtils::MARKETS.us)
    refute_equal(nil, YahooFinance::FinanceUtils::MARKETS.us.nyse.url)
    refute_equal(nil, YahooFinance::FinanceUtils::MARKETS.us.nasdaq.url)
  end

  def test_finance_utils_stock_by_market
    ycl = YahooFinance::Client.new
    assert 0 < ycl.symbols_by_market('us', 'nyse').count
    assert 0 < ycl.symbols_by_market('us', 'nasdaq').count
  end

  def test_finance_utils_companies_by_market
    ycl = YahooFinance::Client.new
    assert 0 < ycl.companies_by_market('us', 'nyse')['nyse'].count
    assert 0 < ycl.companies_by_market('us', 'nasdaq')['nasdaq'].count
  end

  def test_finance_utils_companies
    ycl = YahooFinance::Client.new
    assert 0 < ycl.companies('us', ['nyse', 'nasdaq']).count
    assert 0 < ycl.companies('us', 'nasdaq').count
    assert 0 < ycl.companies('us').count
  end

  def test_finance_utils_sectors
    ycl = YahooFinance::Client.new
    assert 0 < ycl.sectors('us', ['nyse', 'nasdaq']).count
    assert 0 < ycl.sectors('us', 'nasdaq').count
    assert 0 < ycl.sectors('us').count
  end

  def test_finance_utils_industries
    ycl = YahooFinance::Client.new
    assert 0 < ycl.industries('us', ['nyse', 'nasdaq']).count
    assert 0 < ycl.industries('us', 'nasdaq').count
    assert 0 < ycl.industries('us').count
  end
end
