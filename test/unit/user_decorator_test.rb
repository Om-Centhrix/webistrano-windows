require File.dirname(__FILE__) + '/../test_helper'

class UserDecoratorTest < ActiveSupport::TestCase
  
  def test_successful_authentication
    strategy = MockStrategy.new
    user_wrapper = UserDecorator.authenticate("myLogin", "myPassword", strategy)
    assert_equal({ :login => "myLogin", :password => "myPassword" }, user_wrapper.model)
  end
  
  def test_unsuccessful_authentication
    strategy = MockStrategy.new
    user_wrapper = UserDecorator.authenticate("badLogin", "badPassword", strategy)
    assert_nil(user_wrapper.model)
  end
end

class MockStrategy
  
  attr_reader :method_call_count, :user
  
  def initialize()
    @method_call_count = Hash.new { | h, k | h[k] = 0 }
  end
  
  def authenticate(login, password)
    return nil if(login == "badLogin" || password == "badPassword")
    @user = { :login => login, :password => password }
  end
  
  def method_missing(*args)
    @method_call_count[args] += 1
  end
end