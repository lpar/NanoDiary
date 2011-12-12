#!/usr/bin/env ruby
# encoding: UTF-8

# Simple command-line NanoDiary client using JSON REST interface
# Put
#   { "url": "http://user:passwrd@nanodiary.example.com" }
# in ~/.nanodiaryrc

require 'rest-client'
require 'json'

HOME = ENV['HOME'] or raise "No place like $HOME"
preffile = File.open("#{HOME}/.nanodiaryrc") or raise "No ~/.nanodiaryrc"
prefs = JSON.parse(preffile.read)

msg = ARGV.join(' ').gsub(/  */, ' ').strip
if msg.length > 0
  puts RestClient.post prefs['url'], { 'body' => msg }.to_json, :content_type => 'application/json'
end

puts RestClient.get prefs['url'], :accept => 'text/plain'
