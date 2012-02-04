after 'production', 'setup_production'

task :setup_production do
  set :branch, "production"
  set :rails_env, 'production'

  EVEN_PASSENGER_HOSTS = find_servers(:roles => :passenger).each_with_index.map { |s, i| i % 2 == 1 ? s : nil }.compact
  ODD_PASSENGER_HOSTS = find_servers(:roles => :passenger).each_with_index.map { |s, i| i % 2 == 0 ? s : nil }.compact
  EVEN_DB_HOSTS = find_servers(:roles => :db).each_with_index.map { |s, i| i % 2 == 1 ? s : nil }.compact
  ODD_DB_HOSTS = find_servers(:roles => :db).each_with_index.map { |s, i| i % 2 == 0 ? s : nil }.compact

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
      [ ODD_PASSENGER_HOSTS + ODD_DB_HOSTS, EVEN_PASSENGER_HOSTS + EVEN_DB_HOSTS ].each do |hostlist|
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
        [ ODD_PASSENGER_HOSTS, EVEN_PASSENGER_HOSTS ].each do |hostlist|
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
end