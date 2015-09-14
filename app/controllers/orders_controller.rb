class OrdersController < ApplicationController
  def index
    @start = 0
    @limit = 0
    @payments = nil

    smspay = Sample1881::Smspay.new(
      user: session[:setting]['smspay_user'],
      password: session[:setting]['smspay_password'],
      base_url: session[:setting].try(:[], 'smspay_base_url') || "http://api.smspay.devz.no"
    )

    if smspay.login
      response = smspay.orders
      if response.status == 200
        @start = response.body['start']
        @limit = response.body['limit']
        @payments = response.body['docs']
      end
    end
  end
end