require 'faraday_middleware'
module Sample1881
  class Smspay
    attr_accessor :options, :merchant_id, :token
    def initialize(options = {})
      @options = options
    end

    def connection
      ::Faraday.new(url: options[:base_url]) do |conn|
        conn.request :url_encoded
        conn.response :logger
        conn.response :json, content_type: /\bjson$/
        conn.adapter Faraday.default_adapter
      end
    end

    def login
      login = connection.post do |req|
        req.url '/v1/login'
        req.body = {
          user: options[:user],
          password: options[:password]
        }
      end


      if login.status == 200 && login.body.present?
        @merchant_id = login.body['merchant_id']
        @token = "Bearer #{login.body['token']}"
        true
      else
        false
      end
    end

    def orders
      payments = connection.get do |req|
        req.url 'v1/payments'
        req.headers['Authorization'] = @token
        # For curry film only
        req.params = {
          status: 'COMPLETED',
          merchant: '648862675810',
          limit: 10
        }
      end
    end
  end
end