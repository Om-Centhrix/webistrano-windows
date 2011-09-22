module Webistrano
  module Template
    module WindowsBase
      
      CONFIG = Webistrano::Template::Base::CONFIG.dup.merge({
      }).freeze
      
      DESC = <<-'EOS'
        Windows Base template that the other templates use to inherit from.
        Defines basic Capistrano configuration parameters.
        Overrides Capistrano tasks to use mklink instead of ln -s to
        effectively build NTFS symlinks.
      EOS
      
      TASKS =  <<-'EOS'
        # Converts a string path for use with the mklink command
        def do_mklink(path)
          path.gsub("/", "\\\\\\")
        end
      
        # allocate a pty by default as some systems have problems without
        default_run_options[:pty] = true
      
        # set Net::SSH ssh options through normal variables
        # at the moment only one SSH key is supported as arrays are not
        # parsed correctly by Webistrano::Deployer.type_cast (they end up as strings)
        [:ssh_port, :ssh_keys].each do |ssh_opt|
          if exists? ssh_opt
            logger.important("SSH options: setting #{ssh_opt} to: #{fetch(ssh_opt)}")
            ssh_options[ssh_opt.to_s.gsub(/ssh_/, '').to_sym] = fetch(ssh_opt)
          end
        end
        
        namespace :deploy do
          desc <<-DESC
            [internal] Touches up the released code. This is called by update_code \
            after the basic deploy finishes. It assumes a Rails project was deployed, \
            so if you are deploying something else, you may want to override this \
            task with your own environment's requirements.
        
            This task will make the release group-writable (if the :group_writable \
            variable is set to true, which is the default).
          DESC
          task :finalize_update, :except => { :no_release => true } do       
            set :my_link, do_mklink(latest_release)
            set :my_target, do_mklink(shared_path)
        
            # mkdir -p is making sure that the directories are there for some SCM's that don't
            # save empty folders
            run <<-CMD
              /bin/find #{latest_release} -type d -iname .svn -or -type d -iname .git | xargs rm -Rf && \
              rm -rf #{latest_release}/log && cmd /c mklink /D #{my_link}\\\\log #{my_target}\\\\log
            CMD
          end
          
          desc <<-DESC
            Updates the symlink to the most recently deployed version. Capistrano works \
            by putting each new release of your application in its own directory. When \
            you deploy a new version, this task's job is to update the 'current' symlink \
            to point at the new version. You will rarely need to call this task \
            directly; instead, use the 'deploy' task (which performs a complete \
            deploy, including 'restart') or the 'update' task (which does everything \
            except 'restart').
          DESC
          task :symlink, :except => { :no_release => true } do
                    
            set :my_link, do_mklink(current_path)
  
            on_rollback do
              set :my_target, do_mklink(previous_release)
            
              if previous_release
                run "rm -f #{current_path}; cmd /c mklink /D #{my_link} #{my_target}; true"
              else
                logger.important "no previous release to rollback to, rollback of symlink skipped"
              end
            end
        
            set :my_target, do_mklink(latest_release)
        
            run "rm -f #{current_path} && cmd /c mklink /D #{my_link} #{my_target}"
          end
            
          namespace :rollback do
            desc <<-DESC
              [internal] Points the current symlink at the previous revision.
              This is called by the rollback sequence, and should rarely (if
              ever) need to be called directly.
            DESC
            task :revision, :except => { :no_release => true } do
              set :my_link, do_mklink(current_path)
              set :my_target, do_mklink(previous_release)
              
              if previous_release
                run "rm -Rf #{current_path}; cmd /c mklink /D #{my_link} #{my_target}"
              else
                abort "could not rollback the code because there is no prior release"
              end
            end
          end
        end
        
      EOS
    end
  end
end