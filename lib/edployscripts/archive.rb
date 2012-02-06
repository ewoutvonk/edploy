module Edploy
	class Archive
	
		class << self
		
			def extract(archive, target_dir, options = {})
			  cmds = []
			  case archive_type(archive)
			  when :tgz then cmds << "tar -C #{target_dir} -z -x -f #{archive}"
			  when :tbz2 then cmds << "tar -C #{target_dir} -j -x -f #{archive}"
			  when :tar then cmds << "tar -C #{target_dir} -x -f #{archive}"
			  when :zip then cmds << "cd #{target_dir} ; unzip #{archive}"
			  end
			  cmds << "rm -f #{archive}" if options[:remove]
			  system cmds.join(' ; ')
			end
		
			private
		
			def archive_type(archive)
			  archive.sub(/\.tar\.gz$/, '.tgz').sub(/\.tar\.bz2$/, '.tbz2').gsub(/\./, '').downcase.to_sym
			end
		
		end
	
	end
end