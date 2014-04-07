# config/unicorn.rb
application = 'asonas.jp'
deploy_to = "/var/www/#{application}"

listen "/tmp/unicorn_#{application}.sock"
pid "tmp/pids/unicorn.pid"

worker_processes 6
preload_app true

# capistrano 用に RAILS_ROOT を指定
working_directory "#{deploy_to}/current"

if ENV['RAILS_ENV'] == 'production'
  shared_path = "#{deploy_to}/shared"
  stderr_path "#{shared_path}/log/unicorn.stderr.log"
  stdout_path "#{shared_path}/log/unicorn.stdout.log"
end

preload_app true

before_exec do |server|
  ENV["BUNDLE_GEMFILE"] = "#{deploy_to}/current/Gemfile"
end

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!

  old_pid = "#{ server.config[:pid] }.oldbin"
  unless old_pid == server.pid
    begin
      # SIGTTOU だと worker_processes が多いときおかしい気がする
      Process.kill :QUIT, File.read(old_pid).to_i
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
end


