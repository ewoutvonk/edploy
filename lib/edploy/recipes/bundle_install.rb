set :bundle_path, "vendor/bundle"
set :bundle_without, "development test"

namespace :edploy do
  after 'deploy:update_code', 'edploy:bundle_install'
  task :bundle_install do
    commands = []
    [ bundle_path, ".bundle" ].uniq.each do |link_path|
      commands << "mkdir -p #{shared_path}/#{link_path}"
      commands << "ln -nfs #{shared_path}/#{link_path} #{latest_release}/#{link_path}"
    end
    commands << "cd #{latest_release} ; bundle install --path #{shared_path}/#{bundle_path} --local --without #{bundle_without} || bundle install --path #{shared_path}/#{bundle_path} --without #{bundle_without}"
    run commands.join(' ; ')
  end
end
