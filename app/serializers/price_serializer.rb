class PriceSerializer < ActiveModel::Serializer
  attributes :erp_id, :vcc_type, :day_type, :time_from, :time_to, :charge, :created_at
  belongs_to :gantry
end