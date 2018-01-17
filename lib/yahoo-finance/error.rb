module YahooFinance
  class HttpRequestError < Standard Error
    def initialize(code, error)
      super("YahooFinance::HttpRequestError code:#{code}\n body: #{error}\n")
    end 
  end
end
