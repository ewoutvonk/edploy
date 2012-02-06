require 'highline'
require 'fileutils'
# work around problem where HighLine detects an eof on $stdin and raises an err
HighLine.track_eof = false

module Edployify
	
	class Project
		
		class << self
			
			def before_capify_clean
				FileUtils.rm_f('Capfile')
			end

			def after_capify_clean
				check_existing_dir(File.join('config', 'deploy'))
				check_existing_file(File.join('config', 'deploy.rb'))
			end
			
			private
			
			def check_existing_file(file)
				if File.exists?(file)
					highline.choose do |menu|
						menu.prompt = "File `#{file}' exists, what do you want to do?  "
						menu.choice(:ignore) do
						end
						menu.choice(:truncate) do
							File.truncate(file, 0)
						end
						menu.choice(:comment) do
							File.open(file, 'r+') { |f| c = f.readlines.map { |l| "# #{l}" } ; f.rewind ; f.write c.join() ; f.truncate f.pos }
						end
					end
				end
			end

			def check_existing_dir(dir)
				if File.directory?(dir)
					highline.choose do |menu|
						menu.prompt = "Directory `#{dir}' exists, what do you want to do?  "
						menu.choice(:ignore) do
						end
						menu.choice(:remove) do
							FileUtils.rm_rf(dir)
						end
						menu.choice(:move_stages_to_edploy_and_remove) do
							FileUtils.mv Dir.glob("config/deploy/*.rb"), "config/edploy/stages/"
							FileUtils.rm_rf(dir)
						end
						menu.choice(:rename_with_bak_extension) do
							FileUtils.mv(dir, dir + ".bak")
						end
					end
				end
			end
			
			def highline
				@@highline ||= HighLine.new
			end
			
		end
				
	end
	
end