namespace :dploy do
  namespace :apache do
    desc "phased restart of apache on production"
    task :restart, :roles => :passenger do
      run "apache2ctl configtest && sudo /etc/init.d/apache2 restart"
    end
  end
end
