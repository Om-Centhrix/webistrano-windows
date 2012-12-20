if WebistranoConfig[:authentication_method] == :cas
  cas_options = YAML::load_file(RAILS_ROOT+'/config/cas.yml')
  CASClient::Frameworks::Rails::Filter.configure(cas_options[RAILS_ENV])
end

WEBISTRANO_VERSION = '1.5'

ActionMailer::Base.delivery_method = WebistranoConfig[:smtp_delivery_method] 
ActionMailer::Base.smtp_settings = WebistranoConfig[:smtp_settings] 

Notification.webistrano_sender_address = WebistranoConfig[:webistrano_sender_address]

ExceptionNotification::Notifier.exception_recipients = WebistranoConfig[:exception_recipients]
ExceptionNotification::Notifier.sender_address = WebistranoConfig[:exception_sender_address]

#crowd.yml should ideally be a symlink so that the Crowd application username/password is not
#checked into the repository.  Custom dictates the file live in /usr/local/share/webistrano/crowd.yml
CrowdUsersEndpoint.config = YAML::load_file(RAILS_ROOT + '/config/crowd.yml')
