require 'sinatra'
require "sinatra/json"
require "sinatra/reloader" if development?
require 'redis'
require 'uri'

redis = Redis.new host:"127.0.0.1", port:"6379"

post '/:key' do
  url = params[:url]
  return 400 unless valid_http_uri?(url)
  return 404 unless accessible?(url)

  redis.lpush params[:key], url
  json({ message: "success", url: url })
end

get '/:key' do
  url = redis.lpop params[:key]
  json({ url: url })
end

error 400 do
  'Bad request'
end

error 404 do
  'Not Found'
end

def valid_http_uri?(url)
  URI.split(url).first == 'http' || URI.split(url).first == 'https'
end

def accessible?(url)
  system "youtube-dl", "--get-id", url rescue false
end
