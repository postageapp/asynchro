require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'test/unit'

$: << File.expand_path(File.join(*%w[ .. lib ]), File.dirname(__FILE__))
$: << File.dirname(__FILE__)

require 'asynchro'

class Test::Unit::TestCase
  include Asynchro::TestHelper
end
