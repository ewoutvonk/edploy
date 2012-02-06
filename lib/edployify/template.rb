require 'fileutils'
require 'erb'

module Edployify
	
	class Dir
		def initialize(path, base_path)
			@path = File.join(base_path, path)
		end
		
		def mkdir
			FileUtils.mkdir_p(@path)
		end
	end
	
	class Template
		
		TEMPLATES_DIR = File.expand_path('../../../templates', __FILE__)

		def initialize(path, templates_base, project_base)
			@template = File.join(templates_base, path)
			@target = File.join(project_base, path.sub(/\.erb$/, ''))
		end
		
		def generate(local_binding)
      content = ::ERB.new(IO.read(@template)).result(local_binding)
		  if File.exists?(@target)
		    warn "[skip] '#{@target}' already exists"
		  elsif File.exists?(@target.downcase)
		    warn "[skip] '#{@target.downcase}' exists, which could conflict with `#{@target}'"
		  else
		    unless File.exists?(File.dirname(@target))
		      puts "[add] making directory '#{File.dirname(@target)}'"
		      FileUtils.mkdir(File.dirname(@target))
		    end
		    puts "[add] writing '#{@target}'"
		    File.open(@target, "w") { |f| f.write(content) }
		  end
		end

		class << self
			
			def templates
				@@templates ||= init(:templates)
			end
			
			def dirs
				@@dirs ||= init(:dirs)
			end
			
			def make_dirs
				dirs.each do |dir|
					dir.mkdir
				end
			end
			
			def generate_templates(local_binding)
				templates.each do |template|
					template.generate(local_binding)
				end
			end

			private

			def init(type)
				@@entries ||= { :templates => [], :dirs => [] }
				if @@entries[:templates].empty? && @@entries[:dirs].empty?
					::Dir["#{TEMPLATES_DIR}/config/edploy/**/*"].each do |fqpn|
						entry = fqpn.sub(/^#{TEMPLATES_DIR}\//, '')
						if File.directory?(fqpn)
							@@entries[:dirs] << Edployify::Dir.new(entry, ::RAILS_ROOT)
						elsif entry.end_with?('.erb')
							@@entries[:templates] << Edployify::Template.new(entry, TEMPLATES_DIR, ::RAILS_ROOT)
						end
					end
				end
				@@entries[type]
			end
			
		end
		
	end
	
end