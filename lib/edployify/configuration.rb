require 'highline'
require 'yaml'
require 'fileutils'
# work around problem where HighLine detects an eof on $stdin and raises an err
HighLine.track_eof = false

module Dployify
	
	class Configuration
		
		class << self
			
			def configure
				instance.configure
			end
			
			def binding
				instance.send(:binding)
			end
			
			private
			
			def instance
				@@instance ||= self.new
			end
			
		end
		
		CONFIGURATION_KEYS = {
			:application => { :default => Proc.new { |c| File.basename(::RAILS_ROOT).gsub(/[^A-Za-z0-9_]/, '_').gsub(/_+/, '_') }, :type => Symbol },
			:domain => { :default => Proc.new { |c| "#{c[:application]}.com" } },
			:scm => { :default => :git, :type => Symbol },
			:git_shallow_clone => { :default => true, :boolean => true },
			:repository => { :default => Proc.new { |c| "git@HOSTNAME:#{c[:application]}.git" } },
			:git_enable_submodules => { :default => false, :boolean => true },
			:deploy_via => { :default => :fast_remote_cache, :type => Symbol },
			:deploy_to => { :default => Proc.new { |c| "/apps/#{c[:application]}" } },
			:user => { :default => 'deploy' },
			:group => { :default => 'deploy' },
			:normalize_asset_timestamps => { :default => false, :boolean => true },
			:paranoid => { :ssh_option => true, :default => false, :boolean => true },
			:forward_agent => { :ssh_option => true, :default => true, :boolean => true },
			:notify_email => { :default => Proc.new { |c| "support@#{c[:application]}.com" } }
		}
		
		def configure
			CONFIGURATION_KEYS.each do |variable, options|
				if self.respond_to?(:"ask_#{variable}")
					self.send(:"ask_#{variable}", variable, options)
				elsif options[:ssh_option]
					ask_ssh_option(variable, options)
				else
					ask_value(variable, options)
				end
			end
		end
		
		private
		
		def ask_repository(variable, options = {})
			default = base[variable]
			unless default
				preset = Dployify::Preferences.request_preset(:use)
				project = highline.ask("Git project name (without .git): ") { |q| q.default = config[:application] if config[:application] }
				default = preset.sub(/\{PROJECT\}/, project)
				options[:default] = default
			end
			ask_value(variable, options)
		end
		
		def ask_ssh_option(variable, options = {})
			ask_value(variable, options.merge(:base => config[:ssh_options]))
		end

		def ask_value(variable, options = {})
			base = options[:base] || config
			default = base[variable] || options[:default]
			if default.is_a?(Proc)
				default = default.call(config)
			end

			variable_prompt_name = variable.to_s.gsub(/(^|_)[A-Za-z0-9]/, &:upcase).gsub(/_/, ' ')
			question_prompt = "#{variable_prompt_name} " # add trailing space so user input happens on the same line

			value = if options[:boolean]
				highline.agree(question_prompt) do |q|
					q.default = (default ? "y" : "n") unless default.nil?
					q.readline = true
				end
			else
				arguments = [question_prompt]
				arguments << options[:type] if options[:type]
				highline.ask(*arguments) do |q|
					q.default = default if default
				end
			end

			base[variable] = value
			write_file
		end

		##
		
		def config
			unless @config
				edploy_yml = File.join(::RAILS_ROOT, 'config', 'edploy', 'edploy.yml')
				FileUtils.touch edploy_yml
				$edploy_yml = File.open(edploy_yml, "r+")
				at_exit do
					$edploy_yml.close unless $edploy_yml.closed?
				end
				config_contents = $edploy_yml.read
				@config = config_contents.length == 0 ? {} : YAML::load(config_contents)
				$edploy_yml.rewind
				@config[:ssh_options] = {}
			end
			@config
		end
		
		def write_file
			$edploy_yml.write YAML::dump(config)
			$edploy_yml.truncate $edploy_yml.pos
			$edploy_yml.rewind
		end
		
		def highline
			@highline ||= HighLine.new
		end

		def method_missing(method, *args, &block)
			config[method.to_s] || super
		end
		
	end
	
end