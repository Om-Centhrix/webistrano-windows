require File.dirname(__FILE__) + '/../test_helper'

class UserWrapperTest < ActiveSupport::TestCase
  
  def test_authenticate
    strategy = MockStrategy.new
    user_wrapper = UserWrapper.authenticate("myLogin", "myPassword", strategy)
    assert_equal({ :login => "myLogin", :password => "myPassword" }, user_wrapper.user)
  end
end

class MockStrategy
  
  attr_reader :method_call_count, :user
  
  def initialize()
    @method_call_count = Hash.new { | h, k | h[k] = 0 }
  end
  
  def authenticate(login, password)
    @user = { :login => login, :password => password }
  end
  
  def method_missing(*args)
    @method_call_count[args] += 1
  end
end