class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.string :smspay_order_id
      t.integer :amount
      t.text :cancel_reason
      t.string :customer
      t.string :merchant
      t.string :smspay_merchant_id
      t.string :phone
      t.string :reference
      t.string :sms_provider
      t.string :status
      t.text :meta
      t.text :callback
      t.text :payment
      t.text :description
      t.string :invoice
      t.integer :fee
      t.integer :shipping
      t.string :currency
      t.string :state

      t.timestamps
    end
  end
end
