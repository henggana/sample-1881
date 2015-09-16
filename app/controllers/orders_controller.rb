class OrdersController < ApplicationController
  before_action :ensure_setting

  def index
    @orders = Order.all
  end

  def pull
    @payments = nil

    smspay = Sample1881::Smspay.new(
      user: session[:setting]['smspay_user'],
      password: session[:setting]['smspay_password'],
      base_url: session[:setting].try(:[], 'smspay_base_url') || "http://api.smspay.devz.no"
    )

    if smspay.login
      response = smspay.orders(3000)
      if response.status == 200
        @payments = response.body['docs']
        ActiveRecord::Base.transaction do
          @payments.each do |payment|
            existed = Order.where(reference: payment['reference'])
            order_params = {
              smspay_order_id: payment['_id'],
              amount: payment['amount'],
              cancel_reason: payment['cancel_reason'],
              customer: payment['customer'],
              merchant: payment['merchant'],
              smspay_merchant_id: payment['merchantId'],
              phone: payment['phone'],
              reference: payment['reference'],
              sms_provider: payment['smsProvider'],
              status: payment['status'],
              meta: payment['meta'].to_json,
              callback: payment['callback'].to_json,
              payment: payment['payment'].to_json,
              description: payment['description'],
              invoice: payment['invoice'],
              fee: payment['fee'],
              shipping: payment['shipping'],
              currency: payment['currency'],
              state: payment['type']
            }
            if existed.present?
              existed.first.update(order_params) if params[:refresh]
            else
              Order.create(order_params)
            end

          end
        end
      end
    end
    flash[:success] = "Success Pulling data from smspay"
    redirect_to orders_path
  end
end