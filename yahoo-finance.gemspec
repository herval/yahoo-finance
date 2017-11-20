# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "yahoo-finance/version"

Gem::Specification.new do |s|
  s.name = "yahoo-finance"
  s.version = YahooFinance::VERSION
  s.author = "Herval Freire"
  s.email = "yahoofinance@hervalicio.us"

  s.homepage = "http://hervalicio.us/blog"
  s.license  = "MIT"
  s.summary  = "A wrapper to Yahoo! Finance market data (quotes and exchange rates) feed"

  s.files    = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  s.require_paths = ["lib"]
  s.has_rdoc = false
  s.extra_rdoc_files = ["README.md", "HISTORY"]

  s.add_runtime_dependency("fastercsv") if RUBY_VERSION < "1.9"

  s.add_dependency 'json'
  s.add_dependency 'nokogiri'
  s.add_dependency 'httpclient'

  s.add_development_dependency "bundler", "~> 1.14"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency "minitest", "~> 5.0"

  s.add_development_dependency 'byebug'
  s.add_development_dependency 'yard'
end
