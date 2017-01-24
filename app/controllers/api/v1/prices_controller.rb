module Api::V1
  class PricesController < ApplicationController
    def index
      prices = Price.all
      render json: prices
    end

    def show
      @price = Price.find(params[:id])
      render json: @price
    end
  end
end
