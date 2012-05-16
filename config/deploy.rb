require 'bundler/capistrano'

set :keep_releases, 11

set :use_sudo, false
set :application, "omniauth-shib-tester"

set :deploy_to, "/var/www/apps/#{application}"

set :scm, :git
set :repository, "git@github.com:ASCTech/omniauth-shib-tester.git"
set :branch, "master"
set :branch, $1 if `git branch` =~ /\* (\S+)\s/m
set :deploy_via, :remote_cache

set :user, 'deploy'
set :ssh_options, { :forward_agent => true, :port => 2200 }

task :staging do
  set :rails_env, "staging"
  role :app, "ruby-test.asc.ohio-state.edu"
  role :web, "ruby-test.asc.ohio-state.edu"
  role :db,  "ruby-test.asc.ohio-state.edu", :primary => true
end

task :production do
  set :rails_env, "production"
  set :branch, 'master'
  role :app, "ruby.asc.ohio-state.edu"
  role :web, "ruby.asc.ohio-state.edu"
  role :db,  "ruby.asc.ohio-state.edu", :primary => true
end

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"

    # hit the server once, so the first user doesn't get a slow page load
    run "curl --insecure --silent https://localhost/ > /dev/null"
  end

  task :seed, :roles => :app do
    run "cd #{current_path} && #{rake} RAILS_ENV=#{rails_env} db:seed"
  end
end

#namespace :deploy do
#  namespace :assets do
#    task :precompile, :roles => :web, :except => { :no_release => true, :cowboy_deploy => true } do
#      from = source.next_revision(current_revision)
#      if capture("cd #{latest_release} && #{source.local.log(from)} vendor/assets/ app/assets/ lib/assets | wc -l     ").to_i > 0
#        run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile}
#      else
#        logger.info "Skipping asset pre-compilation because there were no asset changes"
#      end
#    end
#  end
#end

before "deploy:assets:precompile" do
  run [
    "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml",
    "ln -fs #{shared_path}/uploads #{release_path}/uploads",
    "ln -fs #{shared_path}/tmp/pids #{release_path}/tmp/pids",
    "rm #{release_path}/public/system"
  ].join(" && ")
end

after "deploy:restart", "deploy:cleanup"
