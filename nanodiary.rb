#!/usr/bin/env ruby
# encoding: UTF-8

require 'sinatra'
require 'dm-core'
require 'dm-timestamps'
require 'dm-validations'
require 'dm-migrations'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/nd.sqlite3")

class Entry
  include DataMapper::Resource
  property :id, Serial
  property :body, String, :required => true
  property :created_at, DateTime
  property :updated_at, DateTime
end

DataMapper.auto_upgrade!

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
