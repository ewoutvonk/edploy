# Copyright (c) 2009-2011 by Ewout Vonk. All rights reserved.

module Dployify
  class Transformer
    
    class << self
      
      def transform_settings(settings)
        if settings[:stages]
          stages = settings.delete(:stages)
          transform_settings(settings)
          settings[:stages] = {}
          stages.each do |stage_name, stage_settings|
            transform_settings(stage_settings)
            settings[:stages][stage_name] = stage_settings
          end
        else
          transform_servers(settings) if settings[:servers]
          transform_roles(settings) if settings[:roles]
        end
      end
      
      private
      
      def transform_servers(settings)
        servers = settings[:servers] ? settings.delete(:servers) : {}
        servers.each do |host, serverdef|
          settings[host] = Server(*(serverdef[:roles] || []), serverdef[:options])
        end
      end

      def transform_roles(settings)
        roles = settings[:roles] ? settings.delete(:roles) : {}
        roles.each do |role, roledef|
          settings[role] = Role(*(roledef[:hosts] || []), roledef[:options])
        end
      end
      
    end

  end
end