require 'rake/testtask'
require 'bundler/setup'

Bundler::GemHelper.install_tasks

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end

task :console do
  exec "irb -r yahoo-finance -I ./lib"
end

task :default => :test
