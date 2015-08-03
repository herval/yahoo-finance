# YahooFinance Module for YahooFinance gem
module YahooFinance
  # FinanceUtils Module
  module FinanceUtils
    def self.included(base)
      base.extend(self)
    end

    MARKETS = OpenStruct.new(
      us: OpenStruct.new(
        nasdaq: OpenStruct.new(
          url: "http://www.nasdaq.com/screening/companies-by-name.aspx?letter=0&exchange=nasdaq&render=download"),
        nyse: OpenStruct.new(
          url: "http://www.nasdaq.com/screening/companies-by-name.aspx?letter=0&exchange=nyse&render=download"),
        amex: OpenStruct.new(
          url: "http://www.nasdaq.com/screening/companies-by-name.aspx?letter=0&exchange=amex&render=download")))

    def symbols_by_market(country, market)
      symbols = []
      return symbols unless MARKETS[country][market]
      CSV.foreach(open(MARKETS[country][market].url)) do |row|
        next if row.first == "Symbol"
        symbols.push(row.first.gsub(" ", ""))
      end
      symbols
    end
  end
end
