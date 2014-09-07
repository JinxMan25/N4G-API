root = "/home/root/apps/N4G-API/current"
working_directory root
pid "#{root}/tmp/pids/unicorn.pid"
stderr_path "#{root}/log/unicorn.log"
stdout_path "#{root}/log/unicorn.log"

listen "#{root}/tmp/unicorn.N4G-API.sock"
worker_processes 2
timeout 30
