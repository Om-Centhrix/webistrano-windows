class CrowdUsersEndpoint

  CROWD_APPLICATION_USERNAME = "webistrano"
  CROWD_APPLICATION_PASSWORD = "foobar"
  CROWD_REST_HOST = "localhost"

  USER_INDEX_URL = "http://#{CrowdConfiguration["application"]}:#{CrowdConfiguration["password"]}@#{CrowdConfiguration["host"]}:#{CrowdConfiguration["port"]}/crowd/rest/usermanagement/1/search?entity-type=user"
  USER_GET_URL = "http://#{CrowdConfiguration["application"]}:#{CrowdConfiguration["password"]}@#{CrowdConfiguration["host"]}:#{CrowdConfiguration["port"]}/crowd/rest/usermanagement/1/user?username=__login__&expand=attributes"

  def self.index
    JSON.parse(RestClient.get(USER_INDEX_URL, {:accept => "application/json"}))
  end

  def self.get(login)
    url = USER_GET_URL.gsub("__login__", login)

    begin
      JSON.parse(RestClient.get(url, {:accept => "application/json"}))
    rescue RestClient::ResourceNotFound => e
      nil
    end
  end

end