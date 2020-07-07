# encoding: UTF-8

class CodingOauth < Sinatra::Base

  begin
    cnf = YAML::load_file(File.join(__dir__, 'config.yml'))

    @@url = cnf['url']
    @@client_id = cnf['client_id']
    @@client_secret = cnf['client_secret']
  rescue
    @@url = ENV['URL']
    @@client_id = ENV['CLIENT_ID']
    @@client_secret =  ENV['CLIENT_SECRET']
  end

  configure :development do
    register Sinatra::Reloader
  end

  get '/' do
    @url = @@url
    @client_id = @@client_id
    @client_secret = @@client_secret
    erb :index
  end

  get '/api/oauth/callback' do
    code = params[:code]
    @url = "#{@@url}/api/oauth/access_token?client_id=#{@@client_id}&client_secret=#{@@client_secret}&grant_type=authorization_code&code=#{code}"
    puts @url
    uri = URI.parse(@url)
    respone = Net::HTTP.get(uri)
    respone = JSON.parse(respone)
    puts respone
    access_token = respone['access_token']
    uri = URI.parse("#{@@url}/api/current_user?access_token=#{access_token}")
    respone = Net::HTTP.get(uri)
    @current_user = JSON.parse(respone)
    puts @current_user
    if @current_user['code'] != 0
      redirect '/'
      return
    end
    @current_user = @current_user['data']

    uri = URI.parse("#{@@url}/api/user/email?access_token=#{access_token}")
    respone = Net::HTTP.get(uri)
    @emails = JSON.parse(respone)
    if @emails['code'] != 0
      redirect '/'
      return
    end
    @email = @emails['data'][0]['email']
    @access_token = access_token
    erb :oauth
  end
end
