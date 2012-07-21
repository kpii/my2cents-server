set :application, "my2cents-backend"
set :repository,  "path_to_my2cents-server.git"
set :deploy_to,   "/my2cents_server_path"

set :scm, :git

server "my2cents.example", :app, :web, :db, :primary => true

set :user, "username"
set(:branch, "master") unless exists?(:branch)

default_run_options[:pty] = true

namespace :delayed_job do
  task :start, :roles => :app do
    run "cd #{current_path}; RAILS_ENV=production script/delayed_job -n 6 start"
  end

  task :stop, :roles => :app do
    run "cd #{current_path}; RAILS_ENV=production script/delayed_job stop"
  end

  task :restart, :roles => :app do
    stop
    sleep 2
    start
  end
end

after "deploy:start",   "delayed_job:start" 
after "deploy:stop",    "delayed_job:stop" 
after "deploy:restart", "delayed_job:restart" 

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
#    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

#after "deploy:update_code", "gems:install"

namespace :gems do
  desc "Install gems"
  task :install, :roles => :app do
    run "cd #{current_release} && #{sudo} rake gems:install"
  end
end

require 'hoptoad_notifier/capistrano'
