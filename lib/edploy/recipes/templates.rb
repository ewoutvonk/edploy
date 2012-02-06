require 'erb'
require 'fileutils'
def render_template(local_template)
	template_name = File.basename(local_template)
	file_name = File.basename(template_name, '.erb')
	app = File.basename(File.dirname(local_template))
	path = File.join(deploy_to, app, file_name)
	
  template = ERB.new(IO.read(local_template))
  rendered_template = template.result(binding)
  
  tmp_path = File.join('/tmp/', "#{File.basename(path)}-$CAPISTRANO:HOST$") 
  put(rendered_template, tmp_path, :mode => 0644)
  send run_method, <<-CMD
    sh -c "install -m#{sprintf("%3o",0644)} #{tmp_path} #{path} &&
    rm -f #{tmp_path}"
  CMD
end

TEMPLATES = {}
Dir[File.expand_path("../../config/templates/*", __FILE__)].each do |app|
	TEMPLATES[File.basename(app).to_sym] = {
		:templates => Dir[File.join(app, '*.erb')],
		:config => File.join(app, 'config.rb'),
		:after_config => File.join(app, 'after_config.rb'),
		:activate => File.join(app, 'activate.rb'),
		:deactivate => File.join(app, 'deactivate.rb'),
	}
end

TEMPLATES.each do |application, data|
	eval File.read(data[:config]) if File.exists?(data[:config])
	
	namespace :edploy do
		namespace application do
			after 'deploy:setup', "truvo_deploy:#{application}:config"
			desc "Push #{application} config files to server"
			task :config, :roles => application do
				data[:templates].each do |template|
					render_template(template)
				end
				eval File.read(data[:after_config]) if File.exists?(data[:after_config])
			end
			
			if File.exists?(data[:activate])
				desc "Activate #{application}"
				task :activate, :roles => application do
					eval File.read(data[:activate])
				end
			end
			
			if File.exists?(data[:deactivate])
				desc "Deactivate #{application}"
				task :deactivate, :roles => application do
					eval File.read(data[:deactivate])
				end
			end
		end
	end
end