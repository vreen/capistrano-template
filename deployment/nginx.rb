namespace :nginx do
  
  desc "Setup nginx configuration for this application"
  task :setup, roles: :web do
    template "nginx_unicorn.erb", "/tmp/nginx_conf"
    run "#{sudo} mv /tmp/nginx_conf /etc/nginx/sites-enabled/#{application}"
    restart
  end
  after "deploy:setup", "nginx:setup"

  %w[start stop restart].each do |command|
    desc "#{command.capitalize} nginx"
    task command, roles: :web do
      #run "#{sudo} service nginx #{command}" #debian/ubuntu
      #run "#{sudo} /etc/init.d/nginx #{command}" #suse
      run "#{sudo} systemctl #{command} nginx" #arch
    end
  end
end