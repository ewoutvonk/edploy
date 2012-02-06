namespace :edploy do
  
  %w(deploy:update_code deploy:symlink deploy:setup).each do |task_name|
    [ :before, :after ].each do |milestone|
      
      subdir = "#{milestone}_#{task_name.gsub(/:/, '_')}"
      Dir[File.join(RAILS_ROOT, 'config', 'edploy', 'scripts', 'deploy', subdir, "**", "*")].sort.each do |full_entry|
        next if File.directory?(full_entry)
        
        entry = full_entry[File.join(RAILS_ROOT, 'config', 'edploy', 'scripts', 'deploy', subdir, "/").length..-1]
        roles = (entry.include?('/') ? File.dirname(entry).split('_').map(&:to_sym) : nil)
        options = {}
        options[:roles] = roles if roles
        script_name = File.basename(entry).to_sym

        self.send(milestone, task_name, "edploy:#{script_name}")
        task script_name, options do
          run "cd #{latest_release} ; RAILS_ENV=#{rails_env} PROJECT_PATH=#{latest_release} DEPLOY_USER=#{user} DEPLOY_GROUP=#{group} #{::RAILS_ROOT}/config/edploy/scripts/deploy/#{subdir}/#{entry}"
        end
      end
      
    end
  end
end
