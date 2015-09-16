class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.string :phone
      t.string :first_name
      t.string :last_name
      t.string :company_name
      t.string :result_type
      t.string :address
      t.string :city
      t.string :postal_code
    end
  end
end
