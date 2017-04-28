# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bunq/version'

Gem::Specification.new do |spec|
  spec.name          = "bunq-client"
  spec.version       = Bunq::VERSION
  spec.authors       = [
    'Lars Vonk',
    'Bob Forma',
    'Derek Kraan',
  ]
  spec.email         = [
    'lars.vonk@gmail.com',
    'bforma@zilverline.com',
    'dkraan@zilverline.com',
  ]

  spec.summary       = %q{Ruby client for the bunq public API.}
  spec.description   = %q{www.jortt.nl}
  spec.homepage      = "https://www.jortt.nl"
  spec.license       = "MIT"


  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'rest-client', '~> 2.0'

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.5"
  spec.add_development_dependency "webmock", "~> 2.3.2"
  spec.add_development_dependency "rspec-json_expectations", "~> 2.1"
  spec.add_development_dependency "codecov", "~> 0.1.10"
end
