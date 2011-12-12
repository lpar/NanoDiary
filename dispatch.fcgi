#!/usr/bin/ruby

require 'rubygems'

Gem.path.unshift("/home/meta/ruby/gems")

require 'sinatra'
 
module Rack
  class Request
    def path_info
      @env["REDIRECT_URL"].to_s
    end
    def path_info=(s)
      @env["REDIRECT_URL"] = s.to_s
    end
  end
end

require '/home/meta/public_html/nd/nanodiary'

builder = Rack::Builder.new do
  use Rack::ShowStatus
  use Rack::ShowExceptions

  map '/' do
    run NanoDiary.new
  end
end

Rack::Handler::FastCGI.run(builder)
