class GantrySerializer < ActiveModel::Serializer
  attributes :erp_id, :name, :major_road_name, :latitude, :longitude, :updated_at
end