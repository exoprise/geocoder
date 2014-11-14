require 'geocoder/results/base'

module Geocoder::Result
  class Maxmind < Base

    ##
    # Name of the MaxMind service being used.
    #
    def service_name
      # it would be much better to infer this from the length of the @data
      # array, but MaxMind seems to send inconsistent and wide-ranging response
      # lengths (see https://github.com/alexreisner/geocoder/issues/396)
      Geocoder.config.maxmind[:service]
    end

    # now its JSON return just provide some simple access
    #def data_hash
    #  @data_hash ||= Hash[*field_names.zip(@data).flatten]
    #end

    #NOTE: i really don't love this class and implementation but fine for now
    # to contribute back we would need to rationalize

    def location
      @data['location']
    end

    def coordinates
      [location['latitude'].to_f, location['longitude'].to_f]
    end

    def address(format = :full)
      s = state_code.to_s == "" ? "" : ", #{state_code}"
      "#{city}#{s} #{postal_code}, #{country_code}".sub(/^[ ,]*/, "")
    end

    def city
      @data['city']
    end

    def city_name
      city['names']['en']
    end

    def subdivisions
      @data['subdivisions']
    end

    def state
      #data_hash[:region_name] || data_hash[:region_code]
      subdivisions['names']['en']
    end

    def state_code
      @data['subdivisions']['iso_code']
    end

    def country #not given by MaxMind
      @data['country']
    end

    def country_code
      country['iso_code']
    end

    def postal
      @data['postal']
    end

    def postal_code
      postal['code']
    end

    def traits
      @data['traits']
    end

    def queries_remaining
      @data['maxmind']['queries_remaining']
    end

    def method_missing(method, *args, &block)
      if @data.has_key?(method)
        return @data[method]
      else
       super
      end
    end

    def respond_to?(method)
      if @data.has_key?(method)
        true
      else
        super
      end
    end
  end
end
