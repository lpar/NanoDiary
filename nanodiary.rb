#!/usr/bin/env ruby
# encoding: UTF-8

require 'dm-core'
require 'dm-timestamps'
require 'dm-validations'
require 'dm-migrations'

class DateTime
  def relative
    secs = (60400*(DateTime.now - self)).to_i
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

class NanoDiary < Sinatra::Application

  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/nd.sqlite3")

  class Entry
    include DataMapper::Resource
    property :id, Serial
    property :body, String, :required => true
    property :created_at, DateTime
    property :updated_at, DateTime
  end

  DataMapper.auto_upgrade!

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

end
