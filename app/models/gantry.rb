require 'rubygems'
require 'net/http'
require 'nokogiri'
require 'csv'
require 'json'

class Gantry < ActiveRecord::Base
  self.table_name = 'gantries'
  self.primary_key = :erp_id
  has_many :prices

  # Retrieves a list of all the ERP gantries
  def self.erp_list
    res = Net::HTTP.get_response(URI.parse('https://www.mytransport.sg/content/mytransport/home/myconcierge/erprates.html'))
    html = Nokogiri::HTML(res.body)
    erp_list_string = html.css('input#erp_list').attribute('value').to_s
    "erpId,zoneId,erpGantry,majorRoadType,erpMajorRoad,latitude,longitude,date\n" + erp_list_string.gsub(';', "\n")
  end

  def self.make_gantries
    CSV.parse(self.erp_list, {headers: true}) do |row|
      gantry = Gantry.new({
                              erp_id:          row['erpId'],
                              name:            row['erpGantry'],
                              zone_id:         row['zoneId'],
                              major_road_name: row['erpMajorRoad'],
                              major_road_type: row['majorRoadType'],
                              latitude:        row['latitude'],
                              longitude:       row['longitude']
                          })
      gantry.save!
    end
  end



end
