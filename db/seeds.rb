# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'rubygems'
require 'net/http'
require 'nokogiri'
require 'csv'
require 'json'

class ERPData
  @url = 'https://www.mytransport.sg/content/mytransport/home/myconcierge/erprates/jcr:content/par/erprates.rates'
  @erpIds = []
  @zoneIds = []
  @vccTypes = {
      "passenger_car" => 1,
      "motorcycles" => 2,
      "heavy" => 3,
      "very_heavy" => 4
  }
  @dayTypes = {
      "weekday" => 0,
      "weekend" => 1
  }
  def self.main()
    CSV.parse(erp_list, {headers: true}) { |row| @erpIds << row["erpId"]; @zoneIds << row["zoneId"] }
    params = "?id=#{erp_id}&zoneId=#{zone_id}&vccType=#{vcc_type}&dayType=#{day_type}"
    rates = fetch_rates(params)


    for i in 0..@erpIds.size-1
      erp_id = @erpIds[i]
      zone_id = @zoneIds[i]
      @vccTypes.each do |key,value|
        vcc_type = value
        vcc_name = key
        @dayTypes.each do |key,value|
          day_type = value
          {}
        end
      end
    end
  end

  # Retrieves a list of all the ERP gantries
  def self.erp_list
    res = Net::HTTP.get_response(URI.parse("https://www.mytransport.sg/content/mytransport/home/myconcierge/erprates.html"))
    html = Nokogiri::HTML(res.body)
    erp_list_string = html.css('input#erp_list').attribute("value").to_s
    erp_list_string = "erpId,zoneId,erpGantry,majorRoadType,erpMajorRoad,latitude,longitude,date\n" + erp_list_string.gsub(';', "\n")
    return erp_list_string
  end

  # Retrieves the time range and price
  def self.fetch_rates(params)
    res = Net::HTTP.get_response(URI.parse(@url+params))
    html = Nokogiri::HTML(res.body)
    time_intervals = html.css('.scv_result_detail .erp_result_cont .erp_result_ti')
    time_intervals = time_intervals.map{|ti| ti.text }
    prices = html.css('.scv_result_detail .erp_result_cont .erp_result_pr')
    prices = prices.map{|pr| pr.text }
    rates = Hash[time_intervals.zip(prices)]
    return rates
  end

  def parse_time(time_string)
    timeFrom, timeTo = time_string.split(' - ')[0], time_string.split(' - ')[1]
    timeFrom = Date.parse(timeFrom).iso8601
    timeTo = Date.parse(timeTo).iso8601
    return [timeFrom, timeTo]
  end
end