set_default(:unicorn_user) { user }
set_default(:unicorn_pid) { "#{current_path}/tmp/pids/unicorn.pid" }
set_default(:unicorn_config) { "#{shared_path}/config/unicorn.rb" }
set_default(:unicorn_log) { "#{shared_path}/log/unicorn.log" }
set_default(:unicorn_workers, 2)

namespace :unicorn do
  desc "Setup Unicorn initializer and app configuration"
  task :setup, roles: :app do
    run "mkdir -p #{shared_path}/config"
    template "unicorn.rb.erb", unicorn_config
    #template "unicorn_init.erb", "/tmp/unicorn_init"                       #initscript
    template "unicorn_session.erb", "/tmp/unicorn_init"                     #systemd unit
    run "chmod +x /tmp/unicorn_init"
    #run "#{sudo} mv /tmp/unicorn_init /etc/init.d/unicorn_#{application}"  #suse, debian, ubuntu
    run "#{sudo} mv /tmp/unicorn_init /usr/lib/systemd/system/unicorn_#{application}.service" #arch
    #run "#{sudo} update-rc.d -f unicorn_#{application} defaults" #ubuntu

    run "#{sudo} systemctl daemon-reload"                                   #tell systemd to rescan available units
    run "#{sudo} systemctl enable unicorn_#{application}"                   #arch / systemd
  end
  after "deploy:setup", "unicorn:setup"

  %w[start stop restart].each do |command|
    desc "#{command} unicorn"
    task command, roles: :app do
      #run "service unicorn_#{application} #{command}"                      #debian/ubuntu
      #run "/etc/init.d/unicorn_#{application} #{command}"                  #suse
      run "#{sudo} systemctl #{command} unicorn_#{application}"             #arch
    end
    after "deploy:#{command}", "unicorn:#{command}"
  end
end

