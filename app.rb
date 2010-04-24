require 'rubygems'
require 'sinatra'
require 'activerecord'
require 'haml'

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => 'db/development.sqlite3'
)

class Uri < ActiveRecord::Base
end

before do 
  content_type "text/html", :charset => "utf-8"
end

get '/' do
  haml :index
end

get '/info/:hash' do
  @uri = Uri.find_by_uri_hash(params[:hash])
  haml :info
end

get '/:hash' do
  uri = Uri.find_by_uri_hash(params[:hash])
  thorw :halt, [404, not_found] unless uri
  s = Uri.update(uri.id, :count => uri.count.to_i+1)
  redirect "http://#{uri.original_uri}"
end

post '/create' do
  c_uri = Uri.find_by_original_uri(params[:original_uri])
  if c_uri.blank?
    o =  [('0'..'9'),('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten
    string = (0..4).map { o[rand(o.length)] }.join
    uri = Uri.create!(:original_uri => params[:original_uri].gsub(/^http:\/\//,''), :uri_hash => string, :count => 0)
    redirect "/info/#{uri.uri_hash}"
  else
    redirect "/info/#{c_uri.uri_hash}"
  end
end

not_found do
  "Not found"
end
