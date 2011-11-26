# Copyright (c) 2009-2011 by Ewout Vonk. All rights reserved.

require 'highline'
# work around problem where HighLine detects an eof on $stdin and raises an error.
HighLine.track_eof = false

module Dployify
  class Ui
    
    class << self
      
      def ui(ui_objekt = nil)
        @@ui = ui_objekt if ui_objekt
        @@ui ||= HighLine.new
        @@ui
      end
      
      def ask_setting(settings, setting_name, default = nil)
        unless settings[setting_name]
          prompt = default.nil? ? "#{setting_name}: " : "#{setting_name} [#{default}]: "
          settings[setting_name] = ui.ask(prompt) { |q| q.default = default }
        end
        nil
      end
      
      def ask_settings(settings, *keys)
        keys.each do |key|
          ask_setting(settings, key)
        end
      end
      
    end
    
  end
end