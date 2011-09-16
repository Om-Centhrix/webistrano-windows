module Webistrano
  module Template
    module IIS7
      
      CONFIG = Webistrano::Template::WindowsBase::CONFIG.dup.merge({
        :application => 'you IIS site name',
      }).freeze
      
      DESC = <<-'EOS'
        Template for projects that use IIS.
        The basic (re)start/stop tasks of Capistrano are overriden with IIS (appcmd.exe) tasks.
      EOS
      
      TASKS = Webistrano::Template::WindowsBase::TASKS + <<-'EOS'
           
        namespace :deploy do
          task :restart, :roles => :app, :except => { :no_release => true } do
            run "appcmd stop site #{application}"
            sleep(5)
            run "appcmd start site #{application}"
          end
          
          task :start, :roles => :app, :except => { :no_release => true } do
            run "appcmd start site #{application}"
          end
          
          task :stop, :roles => :app, :except => { :no_release => true } do
            run "appcmd stop site #{application}"
          end
        end
        
      EOS
      
    end
  end
end