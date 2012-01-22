set :domain, "www.sayso.com"
set :branch, "production"
set :rails_env, 'production'

server 'db1.truvolabs.com', :memcache, :app, :db, :sphinx, :primary => true
server 'db2.truvolabs.com', :memcache, :app, :db, :sphinx
server 'app1.truvolabs.com', :memcache, :web, :app, :passenger
server 'app2.truvolabs.com', :memcache, :web, :app, :passenger
server 'app3.truvolabs.com', :memcache, :web, :app, :passenger
server 'app4.truvolabs.com', :memcache, :web, :app, :passenger
# TODO: cold deploy and enable, also below in deploy:zero task
# server 'shared1.truvolabs.com', :memcache, :app
# server 'shared2.truvolabs.com', :memcache, :app

UNEVEN_APP_HOSTS = [ "app1.truvolabs.com", "app3.truvolabs.com" ]
EVEN_APP_HOSTS = [ "app2.truvolabs.com", "app4.truvolabs.com" ]

def filter_hosts(hostfilter)
  old_hostfilter = ENV['HOSTFILTER']
  ENV['HOSTFILTER'] = hostfilter.to_s
  yield
  if old_hostfilter.nil?
    ENV.delete('HOSTFILTER')
  else
    ENV['HOSTFILTER'] = old_hostfilter
  end
end     

namespace :deploy do
  desc "phased deploy of app on production"
  task :zero do
    [ UNEVEN_APP_HOSTS + [ "db1.truvolabs.com" ], EVEN_APP_HOSTS + [ "db2.truvolabs.com" ] ].each do |hostlist|
      filter_hosts(hostlist.join(',')) do
        top.deploy.zero_downtime
      end
    end
  end
  
  task :zero_downtime do
    top.deploy.update
    top.deploy.restart
  end

end

namespace :dploy do
  namespace :apache do
    desc "phased restart of apache on production"
    task :restart, :roles => :passenger do
      [ UNEVEN_APP_HOSTS, EVEN_APP_HOSTS ].each do |hostlist|
        filter_hosts(hostlist.join(',')) do
          top.deploy.apache.actual_restart
        end
      end
    end
    
    task :actual_restart, :roles => :passenger do
      run "apache2ctl configtest && sudo /etc/init.d/apache2 restart"
    end
  end
end
