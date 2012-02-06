require 'highline'
require 'yaml'
require 'fileutils'
# work around problem where HighLine detects an eof on $stdin and raises an err
HighLine.track_eof = false

module Edployify
	
	class Preferences
		
		PREFERENCES_FILE = File.join(Dir.home, '.edployify.cfg')
		
		class << self
			
			def get
				instance.get
			end
			
			private
			
			def instance
				@@instance ||= self.new
			end
			
		end
		
		def get
			initial_configure if preferences.empty?
			preferences
		end
		
		def configure
			menu
		end
		
		def request_preset(action)
			list_presets
			ask_preset(action)
		end
		
		private
		
		def initial_configure
			puts "You don't have any git repository presets configured, let's do this first."
			puts ""
			add_preset
			menu
		end
		
		def add_preset
			puts ""
			puts "Define a username, hostname and optionally a basepath for the preset."
			puts "Note: A project name will be defined during the actual edployify run later on.\n"
			puts "Structure: <USERNAME>@<HOSTNAME>:<BASEPATH>/{PROJECT}.git"
			puts "Example: git@github.com:ewoutvonk/edploy.git"
			puts "Example: gituser@my.server.com:myproject.git (if basepath is empty, there is no slash)"
			preset_add(modify_preset)
		end
		
		def modify_preset(preset = nil)
			satisfied = false
			username = nil
			hostname = nil
			basepath = nil
			if preset
				username, hostname, basepath = preset.split(/[@:]|\/?\{PROJECT\}\.git/)
				basepath = nil if basepath.nil? || basepath.empty?
			end
			until satisfied do
				puts ""
				username = highline.ask("Git repository username: ") { |q| q.default = username || 'git' }
				hostname = highline.ask("Git repository hostname: ") { |q| q.default = hostname || 'github.com' }
				basepath = highline.ask("Git repository basepath (optional): ") { |q| q.default = basepath if basepath }
				preset = "#{username}@#{hostname}:#{basepath}#{basepath.empty? ? '' : '/'}{PROJECT}.git"
				puts ""
				highline.choose do |menu|
					menu.prompt = "Current value: `#{preset}'. What do you want to do? "
					menu.choice(:save) { satisfied = true }
					menu.choice(:change) { }
					menu.choice(:abort) { return } unless preferences.empty?
				end
			end
			preset
		end
		
		def edit_preset
			list_presets
			old_preset = ask_preset(:edit)
			new_preset = modify_preset(old_preset)
			preset_update(old_preset, new_preset)
		end
		
		def delete_preset
			list_presets
			preset_delete(ask_preset(:delete))
		end
		
		def list_presets
			puts "\nPresets:\n\n"
			puts (presets_list.each_with_index.map { |entry, i| "    #{i+1}. #{entry}" }.join("\n") + "\n")
		end
		
		def ask_preset(action)
			preset = nil
			begin
				i = highline.ask("Preset to #{action}: ", Integer)
			end until !(preset = preset_get(i-1)).nil?
			preset
		end
		
		def menu
			while true do
				puts ""
				highline.choose do |menu|
					menu.prompt = "Main menu. Please make a choice. "
					menu.choice(:list_presets) { list_presets }
					menu.choice(:add_preset) { add_preset }
					menu.choice(:edit_preset) { edit_preset }
					menu.choice(:delete_preset) { delete_preset }
					menu.choice(:quit) { return }
				end
			end
		end
		
		##
		
		def presets_list
			preferences[:presets]
		end
		
		def preset_add(preset)
			preferences[:presets] << preset
			write_file
		end
		
		def preset_update(old_preset, new_preset)
			delete_preset(old_preset)
			add_preset(new_preset)
		end
		
		def preset_delete(preset)
			preferences[:presets].delete(preset)
			write_file
		end
		
		def preset_get(i)
			preferences[:presets][i]
		end
		
		def preferences
			unless @preferences
				FileUtils.touch PREFERENCES_FILE
				$edployify_cfg = File.open(PREFERENCES_FILE, "r+")
				at_exit do
					$edployify_cfg.close unless $edployify_cfg.closed?
				end
				preferences_contents = $edployify_cfg.read
				@preferences = preferences_contents.length == 0 ? {} : YAML::load(preferences_contents)
				$edployify_cfg.rewind
			end
			@preferences
		end
		
		def write_file
			$edployify_cfg.write YAML::dump(preferences)
			$edployify_cfg.truncate $edployify_cfg.pos
			$edployify_cfg.rewind
		end
		
		def highline
			@highline ||= HighLine.new
		end
		
	end
	
end