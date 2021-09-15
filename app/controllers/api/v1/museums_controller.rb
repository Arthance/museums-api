require "open-uri"

class Api::V1::MuseumsController < Api::V1::BaseController
  def search
    if params[:lng]
      lng = params[:lng]
    end
    if params[:lat]
      lat = params[:lat]
    end
    mapbox_request(lng, lat)
    render json: @museums
  end

  def mapbox_request(lng, lat)
    mapbox_request = "https://api.mapbox.com/geocoding/v5/mapbox.places/museum.json?type=poi&proximity=#{lng},#{lat}&limit=10&access_token=#{ENV["MAPBOX_TOKEN"]}"
    response_serialized = URI.open(mapbox_request).read
    @response = JSON.parse(response_serialized, object_class: Openstruct)
    museums_details
  end

  def museums_details
    @museums = {}
    @response.features.each do |museum|
      museums_name = []
      postcode = ""
      museum.context.each do |e|
        postcode = e.text if e.id.include?("postcode")
      end
      if @museums.key?[postcode]
        museums_name << @museums[postcode]
      end
      museums_name << museum.text
      @museums[postcode] = museums_name.flatten
    end
  end
end
