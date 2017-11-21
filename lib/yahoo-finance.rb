require "httpclient"
require "ostruct"
require "json"
require "cgi"
require "yahoo-finance/version"
require "yahoo-finance/finance-utils"
require "yahoo-finance/historical"
require "yahoo-finance/quotes"
require "yahoo-finance/splits"
require "yahoo-finance/symbols"

module YahooFinance
  # Client for Yahoo Finance Queries
  class Client
    include YahooFinance::FinanceUtils
    include YahooFinance::Quotes
    include YahooFinance::Historical
    include YahooFinance::Symbols

    def http_client
      @http_client ||= HTTPClient.new
    end
  end
end
