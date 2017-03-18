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

    MARKET_NAMES = %w[nyse nasdaq amex]

    Company = Struct.new(:symbol, :name, :last_sale, :market_cap, :ipo_year, :sector, :industry, :summary_quote, :market)
    Sector = Struct.new(:name)
    Industry = Struct.new(:sector, :name)

    def map_company(row, market)
      Company.new(row[0], row[1], row[2], row[3], row[4], row[5], row[6], row[7], market)
    end

    def companies(country, markets = MARKET_NAMES)
      return [] unless MARKETS[country]
      if markets.present?
        markets.map { |market| companies_by_market(country)[market] }.flatten
      else
        companies_by_market(country).values.flatten
      end
    end

    def companies_by_market(country, markets = MARKET_NAMES)
      markets.inject({}) do |h, market|
        companies = []
        next unless MARKETS[country][market]
        CSV.foreach(open(MARKETS[country][market].url)) do |row|
          next if row.first == "Symbol"
          companies << map_company(row, market)
        end
        h[market] = companies
        h
      end
    end

    def sectors(country, markets = MARKET_NAMES)
      companies(country, markets).map { |c| Sector.new(c.sector) }.uniq
    end

    def industries(country, markets = MARKET_NAMES)
      companies(country, markets).map { |c| Industry.new(c.sector, c.industry) }.uniq
    end

    def symbols_by_market(country, market)
      symbols = []
      market = MARKETS.send(country).send(market)
      return symbols if market.nil?
      CSV.foreach(open(market.url)) do |row|
        next if row.first == "Symbol"
        symbols.push(row.first.gsub(" ", ""))
      end
      symbols
    end
  end
end
