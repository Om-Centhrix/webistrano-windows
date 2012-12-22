class CrowdUsersEndpoint

  USER_INDEX_URL = "https://#{CrowdConfiguration["application"]}:#{CrowdConfiguration["password"]}@#{CrowdConfiguration["host"]}:#{CrowdConfiguration["port"]}/crowd/rest/usermanagement/1/search?entity-type=user"
  USER_GET_URL = "https://#{CrowdConfiguration["application"]}:#{CrowdConfiguration["password"]}@#{CrowdConfiguration["host"]}:#{CrowdConfiguration["port"]}/crowd/rest/usermanagement/1/user?username=__login__&expand=attributes"

  CROWD_REST_AUTHENTICATION_URL = "https://#{CrowdConfiguration["application"]}:#{CrowdConfiguration["password"]}@#{CrowdConfiguration["host"]}:#{CrowdConfiguration["port"]}/crowd/rest/usermanagement/1/authentication?username=__login__"
  CROWD_REST_CHANGE_PASSWORD_URL = "https://#{CrowdConfiguration["application"]}:#{CrowdConfiguration["password"]}@#{CrowdConfiguration["host"]}:#{CrowdConfiguration["port"]}/crowd/rest/usermanagement/1/user/password?username=__login__"
  CROWD_REST_PASSWORD_BODY = %(<?xml version="1.0" encoding="UTF-8"?>
    <password>
      <value>__password__</value>
    </password>
  )

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

  def self.authenticate(login, password)
    url = CROWD_REST_AUTHENTICATION_URL.gsub("__login__", login)
    body = CROWD_REST_PASSWORD_BODY.gsub("__password__", password)

    begin
      JSON.parse(RestClient.post(url, body, {:content_type => "application/xml", :accept => "application/json"}))
    rescue RestClient::BadRequest
      return nil
    end
  end

  def self.update_password(login, password)

    url = CROWD_REST_CHANGE_PASSWORD_URL.gsub("__login__", login)
    body = CROWD_REST_PASSWORD_BODY.gsub("__password__", password)

    begin
      RestClient.put(url, body, {:content_type => "application/xml", :accept => "application/json"})
      Hash.new #Successful call to 'put' returns an empty string; Returning an empty hash for API consistency
    rescue RestClient::BadRequest
      raise "Could Not Save Password"
    end
  end

end