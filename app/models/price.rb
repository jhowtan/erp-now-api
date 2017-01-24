class Price < ActiveRecord::Base
  self.table_name = 'prices'
  belongs_to :gantry, foreign_key: :erp_id

  PASSENGER_CARS = 1
  MOTORCYCLES = 2
  HEAVY_VEH = 3
  VERY_HEAVY_VEH = 4

  WEEKDAYS = 0
  WEEKENDS = 1

  def self.process_erp_rates
    erp_ids = []
    zone_ids = []
    CSV.parse(Gantry.erp_list, {headers: true}) { |row| erp_ids << row['erpId']; zone_ids << row['zoneId'] }

    for i in 0..erp_ids.size-1
      erp_id = erp_ids[i]
      zone_id = zone_ids[i]
      for j in 1..4 # vcc_type
        vcc_type = j
        for k in 0..1
          day_type = k
          rates = fetch_rates(erp_id, zone_id, vcc_type, day_type)
          make_prices(rates, erp_id, vcc_type, day_type)
        end
      end
    end
  end

  # Retrieves the time range and price
  def self.fetch_rates(erp_id, zone_id, vcc_type, day_type)
    url = 'https://www.mytransport.sg/content/mytransport/home/myconcierge/erprates/jcr:content/par/erprates.rates'
    params = "?id=#{erp_id}&zoneId=#{zone_id}&vccType=#{vcc_type}&dayType=#{day_type}"
    res = Net::HTTP.get_response(URI.parse(url+params))
    html = Nokogiri::HTML(res.body)
    time_intervals = html.css('.scv_result_detail .erp_result_cont .erp_result_ti')
    time_intervals = time_intervals.map{|ti| ti.text }
    prices = html.css('.scv_result_detail .erp_result_cont .erp_result_pr')
    prices = prices.map{|pr| pr.text }
    Hash[time_intervals.zip(prices)]
  end

  def self.make_prices(rates, erp_id, vcc_type, day_type)
    rates.each do |time_range, charge|
      puts time_range
      range = Price::parse_time(time_range)
      puts range
      puts "#{range[:time_from]} -- #{range[:time_to]}"

      price = Price.new({
                            erp_id: erp_id,
                            vcc_type: vcc_type,
                            day_type: day_type,
                            time_from: range[:time_from],
                            time_to: range[:time_to],
                            charge: charge.gsub('$', '').to_f
                        })
      price.save!
    end
  end

  def self.parse_time(time_string)
    time_from, time_to = time_string.split(' - ')[0], time_string.split(' - ')[1]
    {
        time_from: Time.parse(time_from).strftime("%H:%M:%S"),
        time_to: Time.parse(time_to).strftime("%H:%M:%S")
    }
  end
end

