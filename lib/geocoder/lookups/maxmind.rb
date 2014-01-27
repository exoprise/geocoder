require 'geocoder/lookups/base'
require 'geocoder/results/maxmind'
require 'csv'

module Geocoder::Lookup
  class Maxmind < Base

    def name
      "MaxMind"
    end

    def query_url(query)
      "#{protocol}://geoip.maxmind.com/#{service_code}/" + query.sanitized_text #url_query_string(query)
    end

    private # ---------------------------------------------------------------

    ##
    # Return the name of the configured service, or raise an exception.
    #
    def configured_service!
      if s = configuration[:service] and services.keys.include?(s)
        return s
      else
        raise(
          Geocoder::ConfigurationError,
          "When using MaxMind you MUST specify a service name: " +
          "Geocoder.configure(:maxmind => {:service => ...}), " +
          "where '...' is one of: #{services.keys.inspect}"
        )
      end
    end

    def service_code
      services[configured_service!]
    end

    #def service_response_fields_count
    #  Geocoder::Result::Maxmind.field_names[configured_service!].size
    #end

    #def data_contains_error?(parsed_data)
    #  # if all fields given then there is an error
    #  parsed_data.size == service_response_fields_count and !parsed_data.last.nil?
    #end

    ##
    # Service names mapped to code used in URL.
    #
    def services
      {
        :country => "geoip/v2.0/country",
        :city => "geoip/v2.0/city",
        :city_isp_org => "geoip/v2.0/city_isp_org",
        :omni => "geoip/v2.0/omni"
      }
    end

    def results(query)
      # don't look up a loopback address, just return the stored result
      return [reserved_result] if query.loopback_ip_address?
      doc = fetch_data(query)
      if doc and doc.is_a?(Hash)
        if !doc.has_key?('error')
          return [doc]
        elsif doc['error'] == "INVALID_LICENSE_KEY"
          raise_error(Geocoder::InvalidApiKey) || warn("Invalid MaxMind API key.")
        else
          raise_error(Geocoder::Error, doc['error'])
        end
      end
      return [{}]
    end

    #def parse_raw_data(raw_data)
    #  CSV.parse_line raw_data
    #end

    def reserved_result
      {}
    end

    ##not used anymore, maxmind restful
    #def query_url_params(query)
    #  #now its restful
    #  {
    #    :l => configuration.api_key,
    #    :i => query.sanitized_text
    #  }.merge(super)
    #end
  end
end
