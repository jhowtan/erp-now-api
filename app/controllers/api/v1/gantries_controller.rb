module Api::V1
  class GantriesController < ApplicationController
    def index
      gantries = Gantry.all
      render json: gantries
    end

    def show

    end

    def new

    end

    def create

    end

    def destroy

    end
  end
end
