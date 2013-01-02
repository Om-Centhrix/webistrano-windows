require 'rufus/scheduler'

module CrowdUsersSync

  CROWD_USER_SYNC_INTERVAL = '1h' #Every hour

  def sync
    User.create_or_update_from_crowd_users(CrowdUsersEndpoint.index) if User.table_exists?
  end
  module_function(:sync)

  def start
    sync
    scheduler = Rufus::Scheduler.start_new
    scheduler.every CROWD_USER_SYNC_INTERVAL do
      begin
        sync
      rescue Exception => e
        Rails.logger.error("crowd_users_sync: #{e}")
      end
    end
  end
  module_function(:start)

end