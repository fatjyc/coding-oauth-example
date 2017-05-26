# encoding: UTF-8

class CodingOauth < Sinatra::Base

  begin
    cnf = YAML::load_file(File.join(__dir__, 'config.yml'))

    @@host = cnf['host']
    @@url = cnf['url']
    @@client_id = cnf['client_id']
    @@client_secret = cnf['client_secret']
  rescue
    @@host = ENV['host']
    @@url = ENV['url']
    @@client_id = ENV['client_id']
    @@client_secret =  ENV['client_secret']
  end

  configure :development do
    register Sinatra::Reloader
  end

  get '/' do
    @url = "#{@@url}/oauth_authorize.html?client_id=#{@@client_id}&redirect_uri=#{@@host}/api/oauth/callback&response_type=code&scope=all"
    erb :index
  end

  get '/api/oauth/callback' do
    code = params[:code]
    team = params[:team]
    domain = "https://#{team}.coding.net"
    @url = "#{domain}/api/oauth/access_token?client_id=#{@@client_id}&client_secret=#{@@client_secret}&grant_type=authorization_code&code=#{code}&team=#{team}"
    uri = URI.parse(@url)
    respone = Net::HTTP.get(uri)
    respone = JSON.parse(respone)
    access_token = respone['access_token']
    uri = URI.parse("#{domain}/api/current_user?access_token=#{access_token}")
    respone = Net::HTTP.get(uri)
    @current_user = JSON.parse(respone)
    if @current_user['code'] != 0
      redirect '/'
      return
    end
    @current_user = @current_user['data']
    erb :oauth
  end
end
