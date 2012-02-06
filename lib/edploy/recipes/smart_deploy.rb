namespace :deploy do
  
  desc <<-DESC
    Deploys your project. Does smart deploy if this is activated.
  DESC
  task :default do
    if exists?(:smart_deploy) && smart_deploy
      top.deploy.smart
    else
      top.deploy.code
    end
  end
  
  desc <<-DESC
    Deploys your project. This calls both `update' and `restart'. Note that \
    this will generally only work for applications that have already been deployed \
    once. For a "cold" deploy, you'll want to take a look at the `deploy:cold' \
    task, which handles the cold start specifically.
  DESC
  task :code do
    update
    restart
  end
  
  desc <<-DESC
    Deploys your project. Automagically figures out if deploy:setup, deploy:cold, \
    deploy:migrations or deploy:default is needed.
  DESC
  task :smart do
    project_is_setup = (capture("find #{deploy_to} -mindepth 1 -maxdepth 1 -type d \\( -name 'releases' -o -name 'shared' \\) 2>/dev/null | wc -l").to_i == 2)
    top.deploy.setup unless project_is_setup
    at_least_one_release_exists = capture("find #{releases_path} -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l").to_i > 0
    unless at_least_one_release_exists
      top.deploy.cold
    else
      remote_migrations = capture("find #{latest_release}/db/migrate -type f -name '*.rb' -exec basename {} .rb \\; 2>/dev/null || true").split("\n")
      local_migrations = `find db/migrate -type f -name '*.rb' -exec basename {} .rb \\; 2>/dev/null || true`.split("\n")
      pending_migrations = !(local_migrations - remote_migrations).empty?
      if pending_migrations
        top.deploy.migrations
      else
        top.deploy.code
      end
    end
  end      
  
end