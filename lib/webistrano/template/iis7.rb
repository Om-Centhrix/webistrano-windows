module Webistrano
  module Template
    module IIS7
      
      CONFIG = Webistrano::Template::WindowsBase::CONFIG.dup.merge({
        :application => 'you IIS site name',
        :use_maintenance_site => 'false'
      }).freeze
      
      DESC = <<-'EOS'
        Template for projects that use IIS.
        The basic (re)start/stop tasks of Capistrano are overriden with IIS (appcmd.exe) tasks.
      EOS
      
      TASKS = Webistrano::Template::WindowsBase::TASKS + <<-'EOS'
           
        namespace :deploy do
          desc <<-DESC
            Deploys your project. This calls both 'stop', 'update' and 'start'. \
            It also automatically enables/disables your maintenance site unless \
            you specify :use_maintenance_site = false. Note that this \
            task will generally only work for applications that have already been deployed \
            once. For a "cold" deploy, you'll want to take a look at the 'deploy:cold' \
            task, which handles the cold start specifically.
          DESC
          task :default do
            if fetch(:use_maintenance_site, true)
              logger.info "Enabling maintenace site."
              deploy.web.disable
            else
              stop
            end
            
            update
            
            if fetch(:use_maintenance_site, true)
              logger.info "Disabling maintenace site."
              deploy.web.enable
            else
              start
            end
          end
          
          desc <<-DESC
            Deploy and run pending migrations. This will work similarly to the \
            `deploy' task, but will also run any pending migrations (via the \
            `deploy:migrate' task) prior to updating the symlink. Note that the \
            update in this case it is not atomic, and transactions are not used, \
            because migrations are not guaranteed to be reversible.
          DESC
          task :migrations do
            set :migrate_target, :latest
            
            if fetch(:use_maintenance_site, true)
              logger.info "Enabling maintenace site."
              deploy.web.disable
            else
              stop
            end
            
            update_code
            migrate
            symlink
            
            if fetch(:use_maintenance_site, true)
              logger.info "Disabling maintenace site."
              deploy.web.enable
            else
              start
            end
          end

          task :restart, :roles => :app, :except => { :no_release => true } do
            run "appcmd stop site #{application} && appcmd set site #{application} /serverAutoStart:false"
            sleep(5)
            run "appcmd start site #{application} && appcmd set site #{application} /serverAutoStart:true"
          end
          
          task :start, :roles => :app, :except => { :no_release => true } do
            run "appcmd start site #{application} && appcmd set site #{application} /serverAutoStart:true"
          end
          
          task :stop, :roles => :app, :except => { :no_release => true } do
            run "appcmd stop site #{application} && appcmd set site #{application} /serverAutoStart:false"
          end
          
          namespace :web do
            desc <<-DESC
              Presents a maintenance page to visitors. Disables your application's web \
              interface by stopping your main IIS site under the name {application} \
              and then starts the maintentance site under the name {applcation}-maintance. \ 
            DESC
            task :disable, :roles => :web, :except => { :no_release => true } do
              on_rollback { enable }
              stop
              run "appcmd start site #{application}-maintenance"
            end
        
            desc <<-DESC
              Makes the application web-accessible again. Disables the \
              maintenance site started by deploy:web:disable, and then starts \
              your main IIS site under {application}  which (if your \
              web servers are configured correctly) will make your application \
              web-accessible again.
            DESC
            task :enable, :roles => :web, :except => { :no_release => true } do
              run "appcmd stop site #{application}-maintenance"
              start
            end
          end
          
        end
        
      EOS
      
    end
  end
end