class CatalogsController < ApplicationController
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
        @catalogs = []
        catalog_api = Sample1881::Catalog.new(
          userName: session[:setting]['catalog_user'],
          msisdn: session[:setting]['catalog_msisdn'],
          password: session[:setting]['catalog_password']
        )

        @payments.each do |payment|
          catalog_res = catalog_api.by_phone(payment['phone'])
          if catalog_res.status == 200
            res = Hash.from_xml(catalog_res.body)
            if res['SearchResponse'] && res['SearchResponse']['Results']
              @catalogs << res['SearchResponse']['Results']['ResultItem']
            else
              @catalogs << {}
            end
          end
        end

        # Query all by query = 'null' seems not getting any matching number

        # stop_search = false
        # page = 1
        # pageSize = 300
        # number_of_result = 1
        # result_count = 1
        # while number_of_result.to_i > 0 && @payments.length > 0 && result_count.present?
        #   puts "\npage: #{page} -- number_of_result: #{number_of_result} -- payment_left: #{@payments.length}\n"
        #   catalogs_res = catalog_api.by_page(pageSize, page)
        #   if catalogs_res.status == 200
        #     catalogs = Hash.from_xml(catalogs_res.body)
        #     if catalogs['SearchResponse']['Results']
        #       catalogs['SearchResponse']['Results']['ResultItem'].each do |catalog|
        #         break unless @payments

        #         @payments.each do |payment|
        #           next unless catalog['ContactPoints'].present?
        #           if catalog['ContactPoints']['ContactPoint_Search'].is_a? Array
        #             if catalog['ContactPoints']['ContactPoint_Search'].find { |con| con['Address'] == payment['phone'].to_s }
        #               p catalog['ContactPoints']['ContactPoint_Search']
        #               @catalogs << catalog
        #               @payments.delete_if {|pay| pay == payment }
        #               break
        #             end
        #           elsif catalog['ContactPoints']['ContactPoint_Search'].is_a? Hash
        #             if catalog['ContactPoints']['ContactPoint_Search']['Address'] == payment['phone'].to_s
        #               p catalog['ContactPoints']['ContactPoint_Search']['Address']
        #               @catalogs << catalog
        #               @payments.delete_if {|pay| pay == payment }
        #               break
        #             end
        #           end
        #         end

        #       end # Each result item
        #     end
        #   end # if catalogs_res.status == 200
        #   result_count = catalogs['SearchResponse']['Results'].try(:count)
        #   number_of_result = catalogs['SearchResponse'].try(:[], 'TotalNumberOfResults') || 0
        #   page += 1
        # end # While
        # binding.pry
      end
    end
  end

  def export
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
        @catalogs = []
        catalog_api = Sample1881::Catalog.new(
          userName: session[:setting]['catalog_user'],
          msisdn: session[:setting]['catalog_msisdn'],
          password: session[:setting]['catalog_password']
        )

        @payments.each do |payment|
          catalog_res = catalog_api.by_phone(payment['phone'])
          if catalog_res.status == 200
            res = Hash.from_xml(catalog_res.body)
            if res['SearchResponse'] && res['SearchResponse']['Results']
              catalog = res['SearchResponse']['Results']['ResultItem']
              phone = ''
              if catalog.is_a? Array
                if catalog[0]['ContactPoints'] && catalog[0]['ContactPoints']['ContactPoint_Search']
                  cps = catalog[0]['ContactPoints']['ContactPoint_Search']
                  if cps.is_a? Array
                    found = cps.find {|phone| phone['ContactPointType'] == 'Mobile' && phone['IsMain'] == 'true'}
                    phone = found.try(:[], 'Address')
                  else
                    if cps['ContactPointType'] == 'Mobile' && cps['IsMain'] == 'true'
                      phone = cps.try(:[], 'Address') 
                    end
                  end
                end
                @catalogs << res['SearchResponse']['Results']['ResultItem'][0].merge('MainPhone' => phone)
              else
                if catalog['ContactPoints'] && catalog['ContactPoints']['ContactPoint_Search']
                  cps = catalog['ContactPoints']['ContactPoint_Search']
                  if cps.is_a? Array
                    found = cps.find {|phone| phone['ContactPointType'] == 'Mobile' && phone['IsMain'] == 'true'}
                    phone = found.try(:[], 'Address')
                  else
                    if cps['ContactPointType'] == 'Mobile' && cps['IsMain'] == 'true'
                      phone = cps.try(:[], 'Address') 
                    end
                  end
                end
                @catalogs << res['SearchResponse']['Results']['ResultItem'].merge('MainPhone' => phone)
              end
            else
              @catalogs << {}
            end
          end
        end
      end
    end
    respond_to do |format| 
       format.xlsx {render xlsx: 'export', filename: "payments.xlsx", layout: false}
    end
  end
end