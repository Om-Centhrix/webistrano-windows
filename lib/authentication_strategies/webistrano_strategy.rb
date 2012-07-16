module AuthenticationStrategies
  class WebistranoStrategy
    
    def self.authenticate(login, password)
      u = User.find_by_login_and_disabled(login, nil) # need to get the salt
      u && u.authenticated?(password) ? u : nil
    end
  end
  
end