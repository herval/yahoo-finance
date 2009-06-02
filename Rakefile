require 'rake'
require 'rake/gempackagetask'
require 'fileutils'
require 'lib/yahoo_finance'
include FileUtils

spec = Gem::Specification.new do |s|
  s.name = "yahoo-finance"
  s.version = "0.0.2"
  s.author = "Herval Freire"
  s.email = "herval@hervalicio.us"
  s.homepage = "http://hervalicio.us/blog"
  s.platform = Gem::Platform::RUBY
  s.summary = "A wrapper to Yahoo! Finance market data (quotes and exchange rates) feed"
  s.files = FileList["{bin,lib}/**/*"].to_a
  s.require_path = "lib"
  s.autorequire = "yahoo_finance"
  s.has_rdoc = false
  s.extra_rdoc_files = ["README", "HISTORY"]
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = false
end
