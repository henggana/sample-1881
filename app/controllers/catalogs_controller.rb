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
        catalog = Sample1881::Catalog.new(
          userName: session[:setting]['catalog_user'],
          msisdn: session[:setting]['catalog_msisdn'],
          password: session[:setting]['catalog_password']
        )

        stop_search = false
        page = 1
        pageSize = 300

        catalogs_res = catalog.by_page(300, 1)
        if catalogs_res.status == 200
          catalogs = Hash.from_xml(catalogs_res.body)
          if catalogs['SearchResponse']['Results']
            catalogs['SearchResponse']['Results']['ResultItem'].each do |cat|
              @payemnts.each do |payment|
                if cat['ContactPoints']['ContactPoints_Search'].is_a? Array
                  if cat['ContactPoints']['ContactPoints_Search'].find { |con| con['Address'] =  }
                elsif cat['ContactPoints']['ContactPoints_Search'].is_a? Hash
                  
                end
              end
            end
          end
        end
      end
    end
  end
end