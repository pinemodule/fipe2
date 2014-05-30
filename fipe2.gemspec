# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fipe2/version'

Gem::Specification.new do |spec|
  spec.name          = "fipe2"
  spec.version       = Fipe2::VERSION
  spec.authors       = ["pinemodule"]
  spec.email         = ["riveta@pinmodule.com"]
  spec.summary       = %q{Api for fipe}
  spec.description   = "%q{A library for getting vehicle data from fibe.org}"
  spec.homepage      = "http://pinemodule.com/"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "nokogiri"
  spec.add_development_dependency "httparty"
end
