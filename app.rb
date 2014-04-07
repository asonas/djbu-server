require 'sinatra'
require "sinatra/json"
require "sinatra/reloader" if development?
require 'redis'

redis = Redis.new host:"127.0.0.1", port:"6379"

post '/music' do
  url = params[:url]
  redis.lpush :musics, url
end

get '/music' do
  url = redis.lpop :musics
  json({ url: url })
end
