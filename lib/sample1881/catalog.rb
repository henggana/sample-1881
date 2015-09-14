require 'faraday_middleware'

module Sample1881
  class Catalog
    attr_accessor :options

    def initialize(options = {})
      @options = options
    end

    def connection
      ::Faraday.new(url: 'https://api.1881bedrift.no') do |conn|
        conn.request :url_encoded
        conn.response :logger
        conn.response :json, content_type: /\bjson$/
        conn.adapter Faraday.default_adapter
      end
    end

    def by_phone(phone)
      connection.get do |req|
        req.url 'search/search'
        req.params = {
          userName: options[:userName],
          msisdn: options[:msisdn],
          password: options[:password],
          level: 1,
          phone: phone
        }
      end
    end
  end
end