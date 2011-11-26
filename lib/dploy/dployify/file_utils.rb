# Copyright (c) 2009-2011 by Ewout Vonk. All rights reserved.

module Dployify
  class FileUtils
    
    class << self
      
      def generate(base, files)
        config_dir = File.join(base,'config')
        if File.directory?(config_dir)
          files.each do |file, content|
            create_file(File.join(base, file), content)
          end
        else
          warn "[warn] directory `#{config_dir}' does not exist"
          files.each do |file, content|
            warn "[skip] '#{base}/#{file}'"
          end
        end
      end

      private

      def create_file(file, content)
        if !File.exists?(File.dirname(file))
          puts "[add] creating directory `#{File.dirname(file)}'"
          Dir.mkdir(File.dirname(file))
        end
        if File.exists?(file)
          warn "[skip] `#{file}' already exists"
        elsif File.exists?(file.downcase)
          warn "[skip] `#{file.downcase}' exists, which could conflict with `#{file}'"
        else
          puts "[add] writing `#{file}'"
          File.open(file, "w") { |f| f.write(content) }
        end
      end
            
    end
    
  end
end