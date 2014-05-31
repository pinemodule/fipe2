require "fipe2/version"

module Fipe2
  class VehicleType
  attr_accessor :pk, :name

  def initialize(pk, name)
    self.pk = pk
    self.name = name
  end
end

class VehicleBrand
  attr_accessor :pk, :brand, :vtype

  def initialize(pk, brand, vtype)
    self.pk = pk
    self.brand = brand
    self.vtype = vtype
  end
end

class VehicleModel
  attr_accessor :pk, :model, :vbrand

  def initialize(pk, model, vbrand)
    self.pk = pk
    self.model = model
    self.vbrand = vbrand
  end
end

class VehicleYear
  attr_accessor :pk, :model, :vmodel

  def initialize(pk, model, vmodel)
    self.pk = pk
    self.model = model
    self.vmodel = vmodel
  end
end

class VehicleData
  attr_accessor :fipe_code, :reference, :average_value, :query_date, :vyear

  def initialize(fipe_code, reference, average_value, query_date, vyear)
    self.fipe_code = fipe_code
    self.reference = reference
    self.average_value = average_value
    self.query_date = query_date
    self.vyear = vyear
  end
end

TRANSLATE = {:lblReferencia => 'reference',
              :lblCodFipe => 'fipe_code',
              :lblValor => 'average_value',
              :lblData => 'query_date'}


#TODO: Handle errors, improve api

class VehicleAPI
  BASE_URL = 'http://www.fipe.org.br/web/indices/veiculos/default.aspx'
  BASE_URL_HOST = 'http://www.fipe.org.br'
  BASE_URL_PATH = '/web/indices/veiculos/default.aspx'

  VEHICLE_CAR = 0
  VEHICLE_MOTORBIKE =1
  VEHICLE_TRUNK = 2

  TYPE_DESCRIPTION = {VEHICLE_CAR: 'Cars',
                      VEHICLE_MOTORBIKE: 'Motorbikes',
                      VEHICLE_TRUNK: 'Trunks'}

  TYPE_PARAMS = {VEHICLE_CAR: {:p => 51},
                 VEHICLE_MOTORBIKE: {:p => 52, :v => 'm'},
                 VEHICLE_TRUNK: {:p => 53, :v => 'c'}}
  attr_accessor :_cache_request_data

  def initialize
    self._cache_request_data = {}
  end


  private

  def _get_vehicle_params(vehicle_type)
    TYPE_DESCRIPTION.each do |key, value|
      if (key == vehicle_type || value == vehicle_type)
        return TYPE_PARAMS[key]
      end
    end
  end

  def _update_cache_request_data(data)
    html_doc = Nokogiri::HTML(data)
    html_doc.css('#form1 input[type="hidden"]').each do |node|
      self._cache_request_data[node['name']] = node['value']
    end
  end

  def app_params_to_base_path(params)
    url =  BASE_URL_PATH + '?'
    params.each do |key,value|
      url += "#{key}=#{value}"
    end
    return url
  end

  def _request_data(vehicle_type, data)
    params = _get_vehicle_params(vehicle_type)
    unless params
      Raise 'vehicle type not found'
    end
    # TODO fix this line
    data = data.merge(_cache_request_data)

    uri = URI.parse(BASE_URL_HOST)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = false
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(app_params_to_base_path(params))
    request.add_field('Content-Type', 'application/json')
    # request.body = data.to_json
    request.set_form_data( data )
    response = http.request(request)
    if (response.code.to_i != 200)
      raise "Request error"
    end
    data = response.body
    _update_cache_request_data(data)
    return data
  end


  def _css_select_from_data(selector, data, skip_match=nil)
    html_doc = Nokogiri::HTML(data)
    items = []
    html_doc.css(selector).each do |node|
      self._cache_request_data[node['name']] = node['value']
      if (skip_match && node.text.include?(skip_match))
        next
      end
      items << node
    end
    items
  end

  public

  def clear_cache
    self._cache_request_data = {}
  end

  def get_vehicle_types
    return TYPE_DESCRIPTION
  end

  def get_vehicle_brands(vehicle_type)
    request_data = {'ScriptManager1' => 'UdtMarca|ddlMarca', 'ddlMarca' => ''}
    self.clear_cache()
    data = _request_data(vehicle_type, request_data)
    unless data
      return
    end

    items = _css_select_from_data('select[name="ddlMarca"] option',
                                       data, skip_match='Selecione ')
    vehicle_brands = []
    items.each do |item|
      vehicle_brands << VehicleBrand.new(item['value'], item.text, vehicle_type)
    end
    vehicle_brands
  end


  def get_vehicle_models(brand)
    request_data = {'ScriptManager1' => 'UdtMarca|ddlMarca', 'ddlMarca' => brand.pk, 'ddlModelo' => '0'}
    data = _request_data(brand.vtype, request_data)
    unless data
      return
    end
    items = _css_select_from_data('select[name="ddlModelo"] option', data, skip_match='Selecione')

    vehicle_models = []
    items.each do |item|
      vehicle_models << VehicleModel.new(item['value'], item.text, brand)
    end
    vehicle_models
  end

  def get_vehicle_years(model)
    request_data = {'ScriptManager1' => 'updModelo|ddlModelo', 'ddlMarca' => model.vbrand.pk, 'ddlModelo' => model.pk, }
    data = _request_data(model.vbrand.vtype, request_data)
    unless data
      return
    end
    items = _css_select_from_data('select[name="ddlAnoValor"] option', data, skip_match='Selecione ')
    vehicle_years = []
    items.each do |item|
      vehicle_years << VehicleYear.new(item['value'], item.text, model)
    end
    vehicle_years
  end


  def get_vehicle_data(year)
    request_data = {'ScriptManager1' => 'updAnoValor|ddlAnoValor', 'ddlMarca' => year.vmodel.vbrand.pk, 'ddlModelo' => year.vmodel.pk, 'ddlAnoValor' => year.pk}
    data = _request_data(year.vmodel.vbrand.vtype, request_data)
    unless data
      return
    end
    items = _css_select_from_data('#pnlResultado table td span', data)
    tmp = {}
    items.each do |item|
      label = item['id'].to_sym
      if TRANSLATE.has_key?(label)

        tmp[TRANSLATE[label]] = item.text
      end
    end

    tmp['vyear'] = year
    return VehicleData.new(tmp['fipe_code'],tmp['reference'],tmp['average_value'],tmp['query_date'],tmp['vyear'])

  end
end
end
