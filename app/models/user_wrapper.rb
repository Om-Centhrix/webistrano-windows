class UserWrapper
  
  DEFAULT_STRATEGY = AuthenticationStrategies::WebistranoStrategy
  
  attr_reader :user
  
  def initialize(user)
    @user = user
  end
  
  def self.authenticate(login, password, strategy = DEFAULT_STRATEGY)
    @user = strategy.authenticate(login, password)
    self.new(@user)
  end
end