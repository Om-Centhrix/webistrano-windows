require 'active_support/dependencies'

module AuthenticationStrategies
  
  autoload :CrowdStrategy, "authentication_strategies/crowd_strategy"
  autoload :WebistranoStrategy, "authentication_strategies/webistrano_strategy" 
  
end