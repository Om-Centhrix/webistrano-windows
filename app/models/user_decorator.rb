class UserDecorator < Draper::Base
  decorates :user
  
  DEFAULT_STRATEGY = AuthenticationStrategies::WebistranoStrategy
  
  def self.authenticate(login, password, strategy = DEFAULT_STRATEGY)
    model = strategy.authenticate(login, password)
    self.new(model)
  end
end