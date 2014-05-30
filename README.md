# Fipe2

A library for getting vehicle data from fibe.org

## Installation

Add this line to your application's Gemfile:

    gem 'fipe2'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fipe2

## Usage

 
	vehicle_types = VehicleAPI.new.get_vehicle_types
	vehicle_brands = VehicleAPI.new.get_vehicle_brands(type)
	vehicle_models = VehicleAPI.new.get_vehicle_models(brand)
	vehicle_years = VehicleAPI.new.get_vehicle_years(model)
	vehicle_data = VehicleAPI.new.get_vehicle_data(year)

## Contributing

1. Fork it ( https://github.com/[my-github-username]/fipe2/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
