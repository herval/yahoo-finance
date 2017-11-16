require 'nokogiri'

module YahooFinance
  module Historical
    HISTORICAL_MODES = {
      daily: "1d",
      weekly: "1wk",
      monthly: "1mo"
    }

    def historical_quotes(symbol, options = {})
      options[:period] ||= :daily
      start_date = options[:start_date] || Time.now() - time_from_days(1)
      end_date = options[:end_date] || Time.now()
      params = {
        interval: HISTORICAL_MODES[options[:period]],
        filter: 'history'
      }
      days_per_page = case params[:interval]
                      when HISTORICAL_MODES[:daily]
                        140 # 100 results divided by 5 trading days/week * 7 days/week = number of days per results
                      when HISTORICAL_MODES[:weekly]
                        700 # 7days/week * 100 results
                      when HISTORICAL_MODES[:monthly]
                        2900 # for simplicity assume that all months have 29 days * 100 results (remove duplicates at the end)
                      end
      current_date = start_date.to_time.to_i
      data = []
      while Time.at(current_date) < end_date
        params[:period1] = current_date
        current_end_date = [current_date + time_from_days(days_per_page), end_date.to_time.to_i].min
        params[:period2] = current_end_date
        url = "https://finance.yahoo.com/quote/#{URI.escape(symbol)}/history/?#{params.map{|k, v| "#{k}=#{v}"}.join("&")}"
        data << read_historical(symbol, url)
        current_date = current_end_date + time_from_days(1)
      end
      data.uniq.flatten
    end


    private

    def time_from_days(days)
      24*60*60*days
    end

    def read_historical(symbol, url)
      doc = Nokogiri::HTML(open(url))
      rows = doc.xpath("//table")[0].css('tr')

      return [] if rows.empty?
      cols = rows[0].css('th').to_a
      trade_date_col = cols.index { |c| c.text == 'Date' }
      open_col = cols.index { |c| c.text == 'Open' }
      high_col = cols.index { |c| c.text == 'High' }
      low_col = cols.index { |c| c.text == 'Low' }
      close_col = cols.index { |c| c.text == 'Close*' }
      adjusted_close_col = cols.index { |c| c.text == 'Adj Close**' }
      volume_col = cols.index { |c| c.text == 'Volume' }

      rows.drop(0).inject([]) do |data, row|
        divs = row.css('td')
        if divs[1] && !divs[1].text.include?('Dividend') && !divs[1].text.include?('Stock Split') #Ignore these rows in the table
          data << OpenStruct.new({
            'symbol': symbol,
            'trade_date': Date.parse(divs[trade_date_col]).to_s,
            'open': divs[open_col].text.to_f,
            'high': divs[high_col].text.to_f,
            'low': divs[low_col].text.to_f,
            'close': divs[close_col].text.to_f,
            'adjusted_close': divs[adjusted_close_col].text.to_f,
            'volume': divs[volume_col].text.gsub(/[^\d^\.]/, '').to_f
          })
        end
        data
      end
    end
  end
end
