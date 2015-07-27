class Api::V1::ServerSearchController < Api::ApplicationController 
  def index
    @locations = Location.where(hidden: false).includes(:indices, :certificates, :uptimes, :region)
  end
end
