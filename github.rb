class Github

  attr_accessor :access_token, :client_id, :client_secret

  def initialize(access_token=nil, session_code=nil, get_access_token=false)
    self.access_token = access_token

    if get_access_token and access_token.nil?
      self.access_token = access_token(session_code)
    end

    if ENV['GITHUB_CLIENT_ID'] && ENV['GITHUB_CLIENT_SECRET']
      self.client_id = ENV['GITHUB_CLIENT_ID']
      self.client_secret = ENV['GITHUB_CLIENT_SECRET']
    end
  end

  def access_token(session_code)
    res = self.post('https://github.com/login/oauth/access_token', {:client_id => self.client_id,
                                                                    :client_secret => self.client_secret,
                                                                    :code => session_code}, true)
    res['access_token']
  end

  def get(url, params={}, parse=false)
    result = RestClient.get(url, :params => params, :accept => :json)

    if parse
      return parse_json_responser result
    end

    result
  end

  def post(url, data={}, parse=false)
    result = RestClient.post(url, data, :accept => :json)

    if parse
      return parse_json_responser result
    end

    result
  end

  def parse_json_response(result)
    JSON.parse result
  end

end