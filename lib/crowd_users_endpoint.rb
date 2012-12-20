class CrowdUsersEndpoint

  cattr_accessor :config

  def self.index
    url = "http://#{config['application']}:#{config['password']}@#{config['host']}:#{config['port']}/crowd/rest/usermanagement/1/search?entity-type=user"
    JSON.parse(RestClient.get(url, {:accept => "application/json"}))
  end

  def self.get(login)
    url = "http://#{config['application']}:#{config['password']}@#{config['host']}:#{config['port']}/crowd/rest/usermanagement/1/user?username=__login__&expand=attributes"
    url = url.gsub("__login__", login)

    begin
      JSON.parse(RestClient.get(url, {:accept => "application/json"}))
    rescue RestClient::ResourceNotFound => e
      nil
    end
  end

end