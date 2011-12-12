#!/usr/bin/env ruby
# encoding: UTF-8

require 'dm-core'
require 'dm-timestamps'
require 'dm-validations'
require 'dm-migrations'
require 'json'

TYPES = %w[application/json text/html]

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
    property :body, Text, :required => true
    property :created_at, DateTime
    property :updated_at, DateTime
  end

  DataMapper.auto_upgrade!

  get '/nanodiary.css' do
    send_file 'nanodiary.css'
  end

  get '/', :provides => :json do
    erb 'json/recent', :content_type => "application/json", :layout => false
  end

  get '/' do
    pass unless request.accept? 'text/html'
    erb :index, :type => :html
  end

  get '/', :provides => :text do
    result = ''
    Entry.all(:order => [:created_at.desc]).first(10).each do |entry|
      result += entry.created_at.relative.rjust(4) + " " + entry.body + "\n"
    end
    result
  end

  post '/', :provides => :json do
    pass unless request.media_type == 'application/json'
    logger.info "JSON mode"
    timestamp = DateTime.now.new_offset(-0.25)
    json = request.body.read
    begin
      data = JSON.parse(json)
    rescue JSON::ParserError => e
      logger.info "Bad JSON: " + json
      return [400, "Bad JSON: " + json]
    end
    timestamp = DateTime.json_create(data['created_at']) if data['created_at']
    if !data['body']
      logger.info "Missing body in JSON"
      return [400, 'Missing body']
    end
    entry = Entry.new(:body => data['body'],
                      :created_at => timestamp)
    entry.save
    [200, 'Saved']
  end

  post '/', :provides => :html do
    pass unless request.accept? 'text/html'
    pass unless request.media_type == 'application/x-www-form-urlencoded'
    logger.info "HTML mode"
    if !params[:body]
      raise 400, 'Missing body'
    end
    # I live in -0600, hence this ugly hack
    entry = Entry.new(:body => params[:body], 
                      :created_at => DateTime.now.new_offset(-0.25))
    entry.save
    redirect '/'
  end

  post '/', :provides => :text do
    pass unless request.media_type == 'text/plain'
    logger.info "Text mode"
    entry = Entry.new(:body => request.body.read)
    entry.save
    [200, 'Saved']
  end

  get '/:id' do
    @entry = Entry.get(params[:id])
    if @entry
      erb :entry
    else
      redirect '/'
    end
  end

end
