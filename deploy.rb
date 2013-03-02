require 'bundler/capistrano'

load 'config/deployment/base'
load 'config/deployment/nginx'
load 'config/deployment/unicorn'

server "hostname", :web, :app, :db, primary: true

set :domain, "domain.de"
set :application, "appname"
set :user, "deployer"
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, :git
set :repository, "ssh://deployer@hostname/home/deployer/git/appname/"
set :branch, "master"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

#set :shared_children, shared_children + %w{db}
set :default_environment, {  'PATH' => "$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH" }

after "deploy:restart", "deploy:cleanup"

# Uncomment if you are using Rails' asset pipeline
load 'deploy/assets'

