#!/usr/bin/env ruby
# encoding: UTF-8

require 'sinatra'
require 'dm-core'
require 'dm-timestamps'
require 'dm-validations'
require 'dm-migrations'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/nd.sqlite3")

class User
  include DataMapper::Resource
  property :id, Serial
  property :login, String, :required => true
  property :password, String, :required => true
end

class Entry
  include DataMapper::Resource
  property :id, Serial
  property :body, String, :required => true
  property :created_at, DateTime
  property :updated_at, DateTime
end

DataMapper.auto_upgrade!

# Create or update a user
# There's no nice graphical interface to this, 
# just call it once to set up your login
def passwd(username, password)
  u = User.first_or_create(:login => username)
  u.attributes = { :password => password }
  u.save
end
# e.g. uncomment
#   passwd('mylogin','mypasswrd')
# run the script once, then delete the line

use Rack::Auth::Basic, "Restricted Area" do |username, password|
  u = User.first(:login => username)
  u && password == u.password
end

class DateTime
  def relative
    secs = (Time.now - self.to_time).to_i
    return "#{secs}s" if secs < 60
    min = secs/60
    return "#{min}m" if min < 60
    hr = min/60
    return "#{hr}h" if hr < 24
    day = hr/24
    return "#{day}d" if day < 14
    wks = day / 7
    return "#{wks}w" if wks < 5
    mon = (day / 30.41).to_i
    return "#{mon}M" if mon < 12
    return "#{(day/365.25).to_i}y"
  end
end

get '/nanodiary.css' do
  send_file 'nanodiary.css'
end

get '/' do
  erb :new
end

post '/' do
  @entry = Entry.new(:body => params[:body])
  @entry.save
  redirect '/'
end

get '/:id' do
  @entry = Entry.get(params[:id])
  if @entry
    erb :show
  else
    redirect '/'
  end
end
