require File.expand_path('../../../edployscripts/archive', __FILE__)
require File.expand_path('../../../edployscripts/file_handling', __FILE__)

namespace :edploy do
  
  after 'deploy:setup', 'edploy:setup_project'
  task :setup_project do
    extract_path = File.expand_path('../../config/copy/extract', __FILE__)
    init_scripts_path = File.expand_path('../../config/copy/init_scripts', __FILE__)

    Edploy::FileHandling.iterate_dir_items(extract_path) do |dirname, basename, relative_entry, fqpn|
      Edploy::FileHandling.upload_file(fqpn, "#{shared_path}/tmp") do |tmp_file|
        target_dir = dirname.gsub(/HOME/, '~')
        Edploy::Archive.extract tmp_file, target_dir, :remove => true
      end
    end
    
    Edploy::FileHandling.iterate_dir_items(init_scripts_path) do |dirname, basename, relative_entry, fqpn|
      Edploy::FileHandling.upload_file(fqpn, "#{shared_path}/tmp") do |tmp_file|
        script_name = "#{application}_#{stage}_#{basename}"
        system("sudo sh -c 'test -f /etc/init.d/#{script_name} || { cp #{tmp_file} /etc/init.d/#{script_name} ; chmod 755 /etc/init.d/#{script_name} ; update-rc.d #{script_name} defaults ; }'")
      end
    end
  end
  
end