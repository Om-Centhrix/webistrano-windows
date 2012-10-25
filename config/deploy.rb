set :application, "webistrano"
set :repository,  "https://github.com/PlanetTelexInc/webistrano-windows.git"
set :copy_exclude, [".git", "*.dbml", "database"]

set :deploy_to, "/var/www/sites/webistrano"
set :deploy_via, :remote_cache
set :keep_releases, "3"

set :user, "deployer"
set :password, ""
set :use_sudo, false

set :scm_verbose, false
set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "lorne"                          # Your HTTP server, Apache/etc
role :app, "lorne"                          # This may be the same as your `Web` server
role :db,  "lorne", :primary => true # This is where Rails migrations will run


# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

after "deploy:create_symlink", "deploy:after_symlink"

namespace :deploy do
    task :after_symlink do
        run "rm -f #{latest_release}/config/database.yml && ln -s #{shared_path}/config/database.yml #{latest_release}/config/database.yml"
        run "rm -f #{latest_release}/config/webistrano_config.rb && ln -s #{shared_path}/config/webistrano_config.rb #{latest_release}/config/webistrano_config.rb"
    end
end

# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
