namespace :edploy do
  after 'deploy:setup', 'edploy:bundle_install'
  task :bundle_install do
    commands = []
    commands << "mkdir -p #{shared_path}/.bundle"
    commands << "ln -nfs #{shared_path}/.bundle #{latest_release}/.bundle"
    commands << "mkdir -p #{shared_path}/vendor/bundle"
    commands << "ln -nfs #{shared_path}/vendor/bundle #{latest_release}/vendor/bundle"
    commands << "bundle install --path #{shared_path}/vendor/bundle --local --without development test || bundle install --path #{shared_path}/vendor/bundle --without development test"
    run commands.join(' ; ')
  end
end
