require File.dirname(__FILE__) + '/../test_helper'

class CrowdUsersEndpointTest < ActiveSupport::TestCase

  def test_index

    result = %({"expand":"user","users":[{"link":{"href":"https://localhost:8443/crowd/rest/usermanagement/1/user?username=foo","rel":"self"},"name":"foo"},{"link":{"href":"https://localhost:8443/crowd/rest/usermanagement/1/user?username=kevin","rel":"self"},"name":"kevin"}]})
    expected = {"expand" => "user",
              "users" => [
                {"link" => {"href" => "https://localhost:8443/crowd/rest/usermanagement/1/user?username=foo","rel" => "self"},"name" => "foo"},
                {"link" => {"href" => "https://localhost:8443/crowd/rest/usermanagement/1/user?username=kevin","rel" => "self"},"name" => "kevin"}
           ]}

    mock = flexmock(RestClient)
    mock.should_receive(:get).times(1).and_return(result)

    actual = CrowdUsersEndpoint.index
    assert_equal(expected, actual)
  end


  def test_get_success

    login = "foo"
    result = %({"expand":"attributes",
                "link":{"href":"https://localhost:8443/crowd/rest/usermanagement/1/user?username=foo","rel":"self"},
                "name":"foo","first-name":"Foo","last-name":"Bar","display-name":"Foo Bar","email":"foo@bar.com",
                "password":{"link":{"href":"https://localhost:8443/crowd/rest/usermanagement/1/user/password?username=foo","rel":"edit"}},"active":true,
                "attributes":{"attributes":[
                  {"link":{"href":"https://localhost:8443/crowd/rest/usermanagement/1/user/attribute?username=foo&attributename=invalidPasswordAttempts","rel":"self"},"name":"invalidPasswordAttempts","values":["0"]},
                  {"link":{"href":"https://localhost:8443/crowd/rest/usermanagement/1/user/attribute?username=foo&attributename=requiresPasswordChange","rel":"self"},"name":"requiresPasswordChange","values":["false"]},
                  {"link":{"href":"https://localhost:8443/crowd/rest/usermanagement/1/user/attribute?username=foo&attributename=lastAuthenticated","rel":"self"},"name":"lastAuthenticated","values":["1355964371258"]},
                  {"link":{"href":"https://localhost:8443/crowd/rest/usermanagement/1/user/attribute?username=foo&attributename=passwordLastChanged","rel":"self"},"name":"passwordLastChanged","values":["1355953539300"]}],
                "link":{"href":"https://localhost:8443/crowd/rest/usermanagement/1/user/attribute?username=foo","rel":"self"}}})

    expected =  {"expand" => "attributes",
                 "link" => {"href" => "https://localhost:8443/crowd/rest/usermanagement/1/user?username=foo","rel" => "self"},
                 "name" => "foo","first-name" => "Foo","last-name" => "Bar","display-name" => "Foo Bar","email" => "foo@bar.com",
                 "password" => {"link" => {"href" => "https://localhost:8443/crowd/rest/usermanagement/1/user/password?username=foo","rel" => "edit"}},"active" => true,
                 "attributes" => {"attributes" => [
                   {"link" => {"href" => "https://localhost:8443/crowd/rest/usermanagement/1/user/attribute?username=foo&attributename=invalidPasswordAttempts","rel" => "self"},"name" => "invalidPasswordAttempts","values" => ["0"]},
                   {"link" => {"href" => "https://localhost:8443/crowd/rest/usermanagement/1/user/attribute?username=foo&attributename=requiresPasswordChange","rel" => "self"},"name" => "requiresPasswordChange","values" => ["false"]},
                   {"link" => {"href" => "https://localhost:8443/crowd/rest/usermanagement/1/user/attribute?username=foo&attributename=lastAuthenticated","rel" => "self"},"name" => "lastAuthenticated","values" => ["1355964371258"]},
                   {"link" => {"href" => "https://localhost:8443/crowd/rest/usermanagement/1/user/attribute?username=foo&attributename=passwordLastChanged","rel" => "self"},"name" => "passwordLastChanged","values" => ["1355953539300"]}],
                 "link" => {"href" => "https://localhost:8443/crowd/rest/usermanagement/1/user/attribute?username=foo","rel" => "self"}}}

    mock = flexmock(RestClient)
    mock.should_receive(:get).times(1).and_return(result)

    actual = CrowdUsersEndpoint.get("foo")
    assert_equal(expected, actual)
  end

end