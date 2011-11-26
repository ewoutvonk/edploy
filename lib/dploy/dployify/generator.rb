# Copyright (c) 2009-2011 by Ewout Vonk. All rights reserved.

require 'dploy/dployify/value_types'

module Dployify
  class Generator
    
    class << self

      def generate_settings(app_lifecycle, hsh)
        if [ :stages, :servers, :roles ].all? { |key| hsh[key].nil? }
          if app_lifecycle == :simple
            hsh.merge!(:servers => generate_production_servers("%%domain%%"))
          else
            generate_stages_from_app_lifecycle(hsh, app_lifecycle)
          end
        end
      end
      
      private
      
      def generate_stages_from_app_lifecycle(hsh, app_lifecycle)
        stages = {}
        if app_lifecycle == :dtap
          generate_stage(stages, :staging, :staging, "staging.%%top.domain%%")
          generate_stage(stages, :testing, :testing, "testing.%%top.domain%%")
          generate_stage(stages, :qa, :qa, "qa.%%top.domain%%")
          generate_stage(stages, :production, :production, "www.%%top.domain%%", generate_production_servers("%%top.domain%%"))
        end
        hsh.merge!(:stages => stages)
      end
      
      def generate_production_servers(domain_variable)
        {
          "app1.#{domain_variable}" => {
            :roles => [ :app, :web ]
          },
          "app2.#{domain_variable}" => {
            :roles => [ :app, :web ]
          },
          "db1.#{domain_variable}" => {
            :roles => [ :app, :db ],
            :options => {
              :primary => true
            }
          },
          "db2.#{domain_variable}" => {
            :roles => [ :app, :db ]
          }
        }
      end
      
      def generate_stage(hsh, name, branch, domain, servers = nil)
        servers ||= {
          Code("domain") => {
            :roles => [ :app, :web, :db ],
            :options => {
              :primary => true
            }
          }
        }
        hsh[name] = {
          :branch => branch,
          :domain => domain,
          :servers => servers
        }
      end

    end
    
  end
end