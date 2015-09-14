class SettingForm
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  validates :smspay_user, :smspay_password, :catalog_user, :catalog_msisdn, :catalog_password, presence: true

  attr_accessor :smspay_user, :smspay_password, :smspay_base_url, :catalog_user, :catalog_msisdn, :catalog_password

  def initialize(attributes = {})
    attributes.try(:each) do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end

  def attributes
    {
      smspay_user: smspay_user,
      smspay_password: smspay_password,
      smspay_base_url: smspay_base_url,
      catalog_user: catalog_user,
      catalog_msisdn: catalog_msisdn,
      catalog_password: catalog_password
    }
  end
end