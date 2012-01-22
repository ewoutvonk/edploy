namespace :dploy do
  namespace :web do
    namespace :disable do
      before 'deploy', 'truvo_deploy:web:disable:maintenance'
      before 'deploy:migrations', 'truvo_deploy:web:disable:maintenance'
      task :maintenance, :roles => :passenger do
        on_rollback { run "rm -f #{shared_path}/system/maintenance.html" }
        run "cp #{current_path}/config/dploy/copy/project_files/#{stage}/$(hostname)/public/maintenance.html #{shared_path}/system/ 2>/dev/null || cp #{current_path}/config/dploy/copy/project_files/#{stage}/public/maintenance.html #{shared_path}/system/ 2>/dev/null || cp #{current_path}/public/maintenance.html #{shared_path}/system/ 2>/dev/null"
      end

      before 'deploy:zero_downtime', 'truvo_deploy:web:disable:zero_downtime'
      task :zero_downtime, :roles => :passenger do
        run "mv /var/www/check.txt /var/www/check2.txt 2>/dev/null || true"
        # sudo "/sbin/iptables -D INPUT -p tcp -s 95.170.77.132/26 -m state --state NEW --dport 443 -j ACCEPT 2>/dev/null || true"
      end
    end

    namespace :enable do
      after 'deploy', 'truvo_deploy:web:enable:maintenance'
      after 'deploy:migrations', 'truvo_deploy:web:enable:maintenance'
      task :maintenance, :roles => :passenger do
        run "rm -f #{shared_path}/system/maintenance.html"
      end

      after 'deploy:zero_downtime', 'truvo_deploy:web:enable:zero_downtime'
      task :zero_downtime, :roles => :passenger do
        run "mv /var/www/check2.txt /var/www/check.txt 2>/dev/null || true"
        # sudo "/sbin/iptables -A INPUT -p tcp -s 95.170.77.132/26 -m state --state NEW --dport 443 -j ACCEPT"
      end
    end
  end
end
