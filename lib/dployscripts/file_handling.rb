module Dploy
	class FileHandling
	
		class << self
		
			def upload_file(file, tmp_path, &block)
			  if File.exists?(file)
			    random_string = "#{Time.now.to_i}"
			    tmp_file = "#{tmp_path}/#{random_string}-#{File.basename(file)}"
			    commands << "mkdir -p #{File.dirname(tmp_file)}"
			    put File.read(file), tmp_file, :mode => 0644
			    yield(tmp_file)
			  end
			end

			def iterate_dir_items(base_dir, &block)
			  Dir["#{base_dir}/**"].each do |fqpn|
			    entry = fqpn.sub(/^#{base_dir}\//, '')
			    dirname = File.dirname(entry)
			    filename = File.basename(entry)
			    yield(dirname, filename, relative_entry, fqpn)
			  end
			end
		
		end
	
	end
end