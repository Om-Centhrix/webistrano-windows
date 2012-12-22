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
  
  # Authenticates a user by their user name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    CrowdUsersEndpoint.authenticate(login, password) ? find_by_login_and_disabled(login, nil) : nil
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

    if User.find(self.id).admin? && User.admin_count > 1
      self.save(false)
    end
  end
  
  def make_admin!
    self.admin = 1
    self.save(false)
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

  def self.create_or_update_from_crowd_users(json)

    logins = json["users"].map { | user | user["name"] }
    logins.each do | login |
      user_json = CrowdUsersEndpoint.get(login)
      
      if user_json.nil?
        Rails.logger.error("Crowd Users Sync: could not get user #{login} listed in crowd user index")
        next
      end

      create_or_update_from_crowd_user(user_json)
    end
  end

  def self.create_or_update_from_crowd_user(user_json)

    user_attributes = Hash[ user_json["attributes"]["attributes"].map { | attr | [attr["name"], attr["values"].first] } ]
    user = find_by_login(user_json["name"])
    if user.nil? #user doesn't exist in webistrano db; create a new one
      user = User.new(:login     =>    user_json["name"],
                      :email     =>    user_json["email"])

      user.admin = user_attributes["admin"].to_i
      user.disabled = user_json["active"] ? nil : Time.now

      user.save(false)

    else #user already exists in webistrano do; update existing
      user.email = user_json["email"]
      user.admin = user_attributes["admin"].to_i
      user.disabled = user_json["active"] ? nil : Time.now

      user.save(false)
    end

    user
  end

  protected

    def save_password
      result = nil
      if password_valid?

        result = CrowdUsersEndpoint.update_password(login, @password)
        unless result
          raise "Could Not Save Password" #Shouldn't happen as a normal use case.
                                          #This will only happen if there's a problem with the crowd server or the username is somehow wrong
        end

        @password = nil; @password_confirmation = nil
      end
      result
    end 
    
    def password_required?
      WebistranoConfig[:authentication_method] != :cas
    end

    
end
