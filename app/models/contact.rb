class Contact < ActiveRecord::Base

  class << self
    def import_all(setting, limit = 10)
      smspay = Sample1881::Smspay.new(
        user: setting['smspay_user'],
        password: setting['smspay_password'],
        base_url: setting.try(:[], 'smspay_base_url') || "http://api.smspay.devz.no"
      )

      if smspay.login
        p "===== logged_in smspay"
        response = smspay.orders(limit)
        p "===== 1881 response status: #{response.status}"
        if response.status == 200
          get_catalog(response, setting)
        end
      end
    end
    handle_asynchronously :import_all

    def get_catalog(response, setting)
      @payments = response.body['docs']
      @catalogs = {}
      @contacts = Contact.all
      catalog_api = Sample1881::Catalog.new(
        userName: setting['catalog_user'],
        msisdn: setting['catalog_msisdn'],
        password: setting['catalog_password']
      )

      @payments.each do |payment|
        next if @contacts.where(phone: payment['phone']).present?
        catalog_res = catalog_api.by_phone(payment['phone'])
        if catalog_res.status == 200
          res = Hash.from_xml(catalog_res.body)
          if res['SearchResponse'] && res['SearchResponse']['Results']
            catalog = res['SearchResponse']['Results']['ResultItem']
            phone = ''
            if catalog.is_a? Array
              mobile_is_main = false
              catalog.each_with_index do |cat, index|
                if cat['ContactPoints'] && cat['ContactPoints']['ContactPoint_Search']
                  cps = cat['ContactPoints']['ContactPoint_Search']
                  if cps.is_a? Array
                    found = cps.select { |pho| pho['ContactPointType'] == 'Mobile'}
                    if found.is_a?(Array) && found.count > 1
                      found = cps.find { |pho| pho['ContactPointType'] == 'Mobile' && pho['IsMain'] == 'true'}
                      mobile_is_main = true if found
                      unless found
                        found = cps.find { |pho| pho['ContactPointType'] == 'Mobile'}
                      end
                    else
                      found = cps.find { |pho| pho['ContactPointType'] == 'Mobile'}
                    end
                    phone = found.try(:[], 'Address')
                  else
                    if cps['ContactPointType'] == 'Mobile'
                      phone = cps.try(:[], 'Address') 
                    end
                  end
                  if mobile_is_main
                    @catalogs[payment['phone']] = cat.merge('MainPhone' => phone)
                    break
                  elsif catalog.length == (index + 1)
                    @catalogs[payment['phone']] = cat.merge('MainPhone' => phone)
                  end
                end
              end
            else
              if catalog['ContactPoints'] && catalog['ContactPoints']['ContactPoint_Search']
                cps = catalog['ContactPoints']['ContactPoint_Search']
                if cps.is_a? Array
                  found = cps.select { |pho| pho['ContactPointType'] == 'Mobile'}
                  if found.is_a?(Array) && found.count > 1
                    found = cps.find { |pho| pho['ContactPointType'] == 'Mobile' && pho['IsMain'] == 'true'}
                    unless found
                      found = cps.find { |pho| pho['ContactPointType'] == 'Mobile'}
                    end
                  else
                    found = cps.find { |pho| pho['ContactPointType'] == 'Mobile'}
                  end
                  phone = found.try(:[], 'Address')
                else
                  if cps['ContactPointType'] == 'Mobile'
                    phone = cps.try(:[], 'Address') 
                  end
                end
                @catalogs[payment['phone']] = catalog.merge('MainPhone' => phone)
              end
            end
          else
            @catalogs[payment['phone']] = {}
          end
          catalog = @catalogs[payment['phone']]
          phone = payment['phone']
          if catalog.present?
            if catalog.is_a? Array
              result_type = catalog[0]['ResultType']
              if result_type == 'Company'
                firstname = catalog[0]['CompanyName']
              else
                firstname = catalog[0]['FirstName']
              end
              lastname = catalog[0]['LastName']
              if catalog[0]['Addresses']['Address_Search'].is_a? Array
                address = catalog[0]['Addresses']['Address_Search'][0]['FormattedAddress']
                city = catalog[0]['Addresses']['Address_Search'][0]['City']
                postal_code = catalog[0]['Addresses']['Address_Search'][0]['Zip']
              else
                address = catalog[0]['Addresses']['Address_Search']['FormattedAddress']
                city = catalog[0]['Addresses']['Address_Search']['City']
                postal_code = catalog[0]['Addresses']['Address_Search']['Zip']
              end
            elsif catalog.is_a? Hash
              result_type = catalog['ResultType']
              if result_type == 'Company'
                firstname = catalog['CompanyName']
              else
                firstname = catalog['FirstName']
              end
              lastname = catalog['LastName']
              if catalog['Addresses']['Address_Search'].is_a? Array
                address = catalog['Addresses']['Address_Search'][0]['FormattedAddress']
                city = catalog['Addresses']['Address_Search'][0]['City']
                postal_code = catalog['Addresses']['Address_Search'][0]['Zip']
              else
                address = catalog['Addresses']['Address_Search']['FormattedAddress']
                city = catalog['Addresses']['Address_Search']['City']
                postal_code = catalog['Addresses']['Address_Search']['Zip']
              end
            end
            check = self.where(phone: phone)
            if check.present?
              contact = check.first
              contact.update(
                first_name: firstname,
                last_name: lastname,
                address: address,
                result_type: result_type,
                city: city,
                postal_code: postal_code
              )
              p "===== Update to DB"
            else
              self.create(
                phone: phone,
                first_name: firstname,
                last_name: lastname,
                address: address,
                result_type: result_type,
                city: city,
                postal_code: postal_code
              )
              p "===== Save to DB"
            end
          else
            check = self.where(phone: phone)
            if check.present?
              contact = check.first
              contact.update(
                first_name: '',
                last_name: '',
                address: '',
                result_type: '',
                city: '',
                postal_code: ''
              )
              p "===== Update to DB"
            else
              self.create(
                phone: phone,
                first_name: '',
                last_name: '',
                address: '',
                result_type: '',
                city: '',
                postal_code: ''
              )
              p "===== Save to DB"
            end
          end
          
        end
      end
    end

  end
end