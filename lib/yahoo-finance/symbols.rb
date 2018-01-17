module YahooFinance
  module Symbols

    # Converts a query into a list of potential stocks
    #
    # @param query [String]
    # @return [Array<OpenStruct>] with potential stocks that match the query
    # @example Query for Apple Stock
    #   client = YahooFinance::Client.new
    #   client.symbols("Apple")
    #   => [#<OpenStruct symbol="AAPL", name="Apple Inc.", exch="NAS", type="S", exchDisp="NASDAQ", typeDisp="Equity">]
    #
    def symbols(query)
      read_symbols(query).map { |row| OpenStruct.new(row) }
    end
    
    alias query symbols
    private

    def read_symbols(query)
      response = http_client.get("http://d.yimg.com/autoc.finance.yahoo.com/autoc?query=#{query}&region=US&lang=en-US&callback=YAHOO.Finance.SymbolSuggest.ssCallback")
      response.body.sub!("YAHOO.Finance.SymbolSuggest.ssCallback(", "").chomp!(");")
      json_result = JSON.parse(response.body)
      json_result["ResultSet"]["Result"]
    end

  end
end
