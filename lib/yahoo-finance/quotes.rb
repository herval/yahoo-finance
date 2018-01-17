require 'bigdecimal' 

module YahooFinance
  module Quotes
    SYMBOLS_PER_REQUEST = 50

    # Takes a stock symbols and returns a stock quote
    #
    # @param symbols [String]
    # @param options [Hash]
    # @return [OpenStruct]
    #
    def quote(symbol, options = {})
      quotes([symbol], options).first
    end

    # Takes multiple stock symbols and returns stock quotes for each symbol
    #
    # @param symbols [Array<String>]
    # @param options [Hash]
    # @return [Array<OpenStruct>]
    #
    def quotes(symbols, options = {})
      result = []
      symbols.each_slice(SYMBOLS_PER_REQUEST) do |symbols_slice|
        read_quotes(symbols_slice.join(",")).map do |data|
          if options[:na_as_nil]
            data.each { |key, value| data[key] = nil if value == 'N/A' }
          end
          result << OpenStruct.new(data)
        end
      end
      result
    end

    private

    def read_quotes(symb_str, retry_on_error = true)
      response = http_client.get("https://query1.finance.yahoo.com/v7/finance/quote?symbols=#{::CGI::escape(symb_str)}")
      result = JSON.parse(response.body)
      result["quoteResponse"]["result"]
    end
  end
end
