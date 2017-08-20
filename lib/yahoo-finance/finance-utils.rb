require 'nokogiri'
require 'open-uri'
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

    SYMBOL_CHANGE_URL = "http://www.nasdaq.com/markets/stocks/symbol-change-history.aspx"

    SORT_BY = [
      'EFFECTIVE',
      'NEWSYMBOL',
      'OLDSYMBOL'
    ]

    ORDER = {
      'desc' => 'Y',
      'asc' => 'N'
    }

    def build_url(base_url, params)
      "#{base_url}?#{params.map{|k, v| "#{k}=#{v}"}.join("&")}"
    end

    def symbol_changes(sort_by='EFFECTIVE', order='desc')
      return unless SORT_BY.include?(sort_by)
      return unless ORDER.has_key?(order)
      params = {
        sortby: sort_by,
        descending: ORDER[order]
      }
      (1..20).to_a.map do |page|
        params[:page] = page
        get_symbol_changes(build_url(SYMBOL_CHANGE_URL, params))
      end
    end

    def get_symbol_changes(url)
      doc = Nokogiri::HTML(open(url))
      table = doc.css("#SymbolChangeList_table")
      rows = table.css('tr')
      return [] if rows.empty?

      cols = rows[0].css('th').to_a
      effective_date_col = cols.index { |c| c.text.strip == 'Effective Date' }
      old_col = cols.index { |c| c.text.strip == 'Old Symbol' }
      new_col = cols.index { |c| c.text.strip == 'New Symbol' }

      rows.drop(0).inject([]) do |data, row|
        divs = row.css('td')
        if !divs.empty?
          data << OpenStruct.new({
            effective_date: Date.strptime(divs[effective_date_col].text, '%m/%d/%Y').to_s,
            old_symbol: divs[old_col].text.strip,
            new_symbol: divs[new_col].text.strip
          })
        end
        data
      end
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
