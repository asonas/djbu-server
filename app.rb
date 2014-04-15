require 'sinatra'
require "sinatra/json"
require "sinatra/reloader" if development?
require 'redis'
require 'uri'

redis = Redis.new host:"127.0.0.1", port:"6379"

post "/image" do
  require 'mechanize'
  agent = Mechanize.new
  page = agent.get("http://www.ascii2d.net/imagesearch")
  form = page.forms[1]
  form['uri'] = params[:url]
  result = agent.submit(form)
  links = result.search("div.box div.detail a").map{ |a| a[:href] }
  urls = links.map do |link|
    link if link.include?("illust_id")
  end.compact.take(3)

  json({ message: :success, urls: urls })
end

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
