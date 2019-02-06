# require "bundler/capistrano"
# config valid for current version and patch releases of Capistrano
lock "~> 3.11.0"

set :stages, %w(review production)
set :application, "mmp"
set :repo_url, "git@github.com:tmckenzie/saleschart.git"
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', 'public/uploads')
set :rvm_ruby_version, 'ruby-2.2.5@mmp'
set :passenger_restart_with_touch, true
set :rvm_type, :system

set :application, "mmp"
set :repository, "git@github.com:tmckenzie/saleschart.git"

set :ssh_options, {
    keys: ["/Users/timmckenzie/dev/mmp/mmp.pem"],
    forward_agent: true,
    auth_methods: %w(publickey)
}

set :bundle_cmd, "/usr/local/rvm/gems/ruby-2.2.5@global/bin/bundle"
set :bundle_dir, "/usr/local/rvm.rvm/gems/ruby-2.2.5"

set :deploy_to, '/var/www/apps/mmp'
on roles :all do
  execute :rvm, " gemset create mmp"
end
