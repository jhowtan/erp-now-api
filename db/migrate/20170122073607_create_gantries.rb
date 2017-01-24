class CreateGantries < ActiveRecord::Migration[5.0]
  def change
    create_table :gantries, {:id => false, :primary_key => :erp_id} do |t|
      t.integer :erp_id
      t.string  :name
      t.string  :major_road_name
      t.string  :major_road_type
      t.string  :zone_id
      t.decimal :latitude
      t.decimal :longitude
      t.timestamps
    end

    create_table :prices do |t|
      t.integer  :erp_id
      t.time     :time_from
      t.time     :time_to
      t.float    :charge
      t.integer  :vcc_type
      t.integer  :day_type
      t.timestamps
    end
  end
end
