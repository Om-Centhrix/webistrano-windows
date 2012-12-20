#crowd.yml should ideally be a symlink so that the Crowd application username/password is not
#checked into the repository.  Custom dictates the file live in /usr/local/share/webistrano/crowd.yml
CrowdConfiguration = YAML::load_file(RAILS_ROOT + '/config/crowd.yml')