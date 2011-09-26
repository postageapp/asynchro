# encoding: utf-8

require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rake'
require 'jeweler'

Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "asynchro"
  gem.homepage = "http://github.com/tadman/asynchro"
  gem.license = "MIT"
  gem.summary = %Q{Ruby EventMachine Async Programming Toolkit}
  gem.description = %Q{Provides a number of tools to help make developing and testing asynchronous applications more manageable.}
  gem.email = "github@tadman.ca"
  gem.authors = [ "Scott Tadman" ]

  # Additional dependencies are defined in the Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end
