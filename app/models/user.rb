require 'digest/sha1'
class User < ActiveRecord::Base
  has_many :deployments, :dependent => :nullify, :order => 'created_at DESC'
  
  attr_accessible :login, :email, :password, :password_confirmation, :time_zone, :tz

  attr_accessor :password, :password_confirmation

  validates_presence_of     :login, :email
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  validate :password_valid?

  before_save :save_password
  
  named_scope :enabled, :conditions => {:disabled => nil}
  named_scope :disabled, :conditions => "disabled IS NOT NULL"

  CROWD_APPLICATION_USERNAME = "webistrano"
  CROWD_APPLICATION_PASSWORD = "foobar"
  CROWD_REST_HOST = "localhost"
  CROWD_REST_AUTHENTICATION_URL = "http://#{CROWD_APPLICATION_USERNAME}:#{CROWD_APPLICATION_PASSWORD}@#{CROWD_REST_HOST}:8095/crowd/rest/usermanagement/1/authentication?username=__login__"
  CROWD_REST_CHANGE_PASSWORD_URL = "http://#{CROWD_APPLICATION_USERNAME}:#{CROWD_APPLICATION_PASSWORD}@#{CROWD_REST_HOST}:8095/crowd/rest/usermanagement/1/user/password?username=__login__"
  CROWD_REST_PASSWORD_BODY = %(<?xml version="1.0" encoding="UTF-8"?>
    <password>
      <value>__password__</value>
    </password>
  )
    
  def validate_on_update
    if User.find(self.id).admin? && !self.admin?
      errors.add('admin', 'status can no be revoked as there needs to be one admin left.') if User.admin_count == 1
    end
  end
  
  # Authenticates a user by their user name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)

    url = CROWD_REST_AUTHENTICATION_URL.gsub("__login__", login)
    body = CROWD_REST_PASSWORD_BODY.gsub("__password__", password)

    begin
      RestClient.post(url, body, {:content_type => "application/xml"})
      u = find_by_login_and_disabled(login, nil)
    rescue RestClient::BadRequest
      return nil
    end
  end 

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def remember_token?
    remember_token_expires_at && Time.now < remember_token_expires_at
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    update_attribute(:remember_token_expires_at, self.remember_token_expires_at)
    update_attribute(:remember_token, self.remember_token)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    update_attribute(:remember_token_expires_at, self.remember_token_expires_at)
    update_attribute(:remember_token, self.remember_token)    
  end
  
  def admin?
    self.admin.to_i == 1
  end
  
  def revoke_admin!
    self.admin = 0
    self.save!
  end
  
  def make_admin!
    self.admin = 1
    self.save!
  end
  
  def self.admin_count
    count(:id, :conditions => ['admin = 1 AND disabled IS NULL'])
  end
  
  def recent_deployments(limit=3)
    self.deployments.find(:all, :limit => limit, :order => 'created_at DESC')
  end
  
  def disabled?
    !self.disabled.blank?
  end
  
  def disable
    self.update_attribute(:disabled, Time.now)
    self.forget_me
  end
  
  def enable
    self.update_attribute(:disabled, nil)
  end

  def password_valid?
    errors.add_to_base("password cannot be empty") and return false if @password.blank?
    errors.add_to_base("password confirmation cannot be empty") and return false if @password_confirmation.blank?
    errors.add_to_base("password and password confirmation do not match") unless @password == @password_confirmation
    errors.add_to_base("password must be between 4 and 40 characters long") unless (4..40).to_a.include?(@password.size)

    return errors.empty?
  end

  protected

    def save_password
      if password_valid?

        url = CROWD_REST_CHANGE_PASSWORD_URL.gsub("__login__", login)
        body = CROWD_REST_PASSWORD_BODY.gsub("__password__", password)

        begin
          RestClient.put(url, body, {:content_type => "application/xml"})
        rescue RestClient::BadRequest
          raise "Could Not Save Password"
        end

        @password = nil; @password_confirmation = nil
      end
    end 
    
    def password_required?
      WebistranoConfig[:authentication_method] != :cas
    end

    
end
