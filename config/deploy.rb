# config valid only for Capistrano 3.1
lock '3.4.0'

set :application, 'djbu.ason.as'
set :repo_url, 'git@github.com:asonas/djbu-server.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/var/www/djbu.ason.as'
set :bundle_jobs, 4

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :rbenv_type, :user # or :system, depends on your rbenv setup
set :rbenv_ruby, '2.2.0'
set :linked_dirs, %w{tmp/pids vendor/bundle log}

namespace :deploy do

  desc 'Restart application'
  task :restart do
    invoke 'unicorn:restart'
    on roles(:app), in: :sequence, wait: 5 do
      with rails_env: fetch(:rails_env) do
      end
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart

  desc 'Start application'
  task :start do
    invoke "unicorn:start"
    with rails_env: fetch(:rails_env) do
    end
  end

  task :reload do
    invoke "unicorn:reload"
    with rails_env: fetch(:rails_env) do
    end
  end

  task :stop do
   invoke "unicorn:stop"
   with rails_env: fetch(:rails_env) do
   end
  end

end
