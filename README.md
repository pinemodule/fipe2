# Fipe2

A library for getting vehicle data from fibe.org

## Installation

Add this line to your application's Gemfile:

    gem 'fipe2', :git => 'git://github.com/pinemodule/fipe2.git'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fipe2

## Usage

    	@api = Fipe2::VehicleAPI.new
	vehicle_types = @api.get_vehicle_types
	type = vehicle_types[:VEHICLE_CAR]
	table_references = @api.get_table_reference(type)
	vehicle_brands = @api.get_vehicle_brands(table_references[0])
	vehicle_models = @api.get_vehicle_models(vehicle_brands[0])
	vehicle_years = @api.get_vehicle_years(vehicle_models[0])
	vehicle_data = @api.get_vehicle_data(vehicle_years[0])
	car_type = vehicle_data.vyear.vmodel.vbrand.vdate.vtype
	car_brand = vehicle_data.vyear.vmodel.vbrand
	car_model = vehicle_data.vyear.vmodel
	car_model_year = vehicle_data.vyear
	car_year = vehicle_data.vyear.vmodel.vbrand.vdate
	
## Contributing

1. Fork it ( https://github.com/pinemodule/fipe2/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
