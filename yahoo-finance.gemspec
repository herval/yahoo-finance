lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "yahoo-finance/version"

spec = Gem::Specification.new do |s|
  s.name = "yahoo-finance"
  s.version = YahooFinance::VERSION
  s.author = "Herval Freire"
  s.email = "yahoofinance@hervalicio.us"
  s.homepage = "http://hervalicio.us/blog"
  s.summary = "A wrapper to Yahoo! Finance market data (quotes and exchange rates) feed"
  s.files = ["lib/yahoo-finance.rb", "lib/yahoo-finance/version.rb", "lib/yahoo-finance/finance-utils.rb"]
  s.require_path = "lib"
  s.has_rdoc = false
  s.extra_rdoc_files = ["README.md", "HISTORY"]
  s.add_runtime_dependency("fastercsv") if RUBY_VERSION < "1.9"
  s.add_dependency 'json'
  s.add_development_dependency 'bundler', '~> 1.10'
  s.add_development_dependency 'rake', '~> 10.0'
  s.add_development_dependency 'test-unit'
end
