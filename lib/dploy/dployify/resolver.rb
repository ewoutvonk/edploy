# Copyright (c) 2009-2011 by Ewout Vonk. All rights reserved.

require File.expand_path('../value_types', __FILE__)

module Dployify
  class Resolver
    
    class << self

      def resolve_variables_in_settings(settings)
        has_stages = !settings[:stages].nil?
        stages = has_stages ? settings.delete(:stages) : {}
        settings[:stages] = {} if has_stages
        resolve_flat_level_variables(settings, {})
        stages.each do |stage_name, stage_settings|
          resolve_flat_level_variables(stage_settings, settings)
          settings[:stages][stage_name] = stage_settings
        end
      end
      
      private
      
      def resolve_flat_level_variables(settings, top_settings = {})
        keys = settings.keys
        keys.each do |key|
          resolved_key = resolve(key, key, settings, top_settings)
          resolved_value = resolve(key, settings[key], settings, top_settings)
          settings.delete(key)
          settings[resolved_key] = resolved_value
        end
      end
      
      def resolve(key, value, settings, top_settings = {})
        if value.is_a?(::String)
          resolve_variables(key, value, settings, top_settings)
        elsif value.is_a?(CommentLine)
          CommentLine(resolve_variables(key, value.value, settings, top_settings))
        elsif value.is_a?(Code)
          Code(resolve_variables(key, value.value, settings, top_settings))
        elsif value.is_a?(Comment)
          Comment(resolve_variables(key, value.value, settings, top_settings))
        elsif value.is_a?(WithSideComment)
          WithSideComment(resolve_variables(key, value.value, settings, top_settings), value.comment)
        elsif value.is_a?(WithTopComment)
          WithTopComment(resolve_variables(key, value.value, settings, top_settings), value.comment)
        else
          value
        end
      end
      
      def resolve_variables(key, value, settings, top_settings = {})
        all_variables = value.scan(/(%%[^%]+%%)/).flatten.map { |item| item.gsub(/(^%%|%%$)/, '') }
        top_variables = all_variables.select { |variable| variable =~ /^top\./ }.map { |variable| variable.gsub(/^top\./, '') }
        variables = all_variables.reject { |variable| variable =~ /^top\./ }
        intermediate = replace_variables(key, value, variables, settings, false)
        replace_variables(key, intermediate, top_variables, top_settings, true)
      end
      
      def replace_variables(key, value, variables, settings, is_top)
        variables.each do |variable|
          value = replace_variable(key, value, variable, settings, is_top ? /%%top\.#{variable}%%/ : /%%#{variable}%%/)
        end
        value
      end
      
      def replace_variable(key, value, variable, settings, regex)
        abort "You have an erroneous deployify config. A variable is trying to reference itself." if variable.to_s == key.to_s
        abort "Your settings dont have a key named #{variable} or :#{variable}!" unless settings.keys.include?(variable.to_sym) || settings.keys.include?(variable)
        value.gsub(regex, settings[variable.to_sym] || settings[variable.to_s])
      end
      
    end
    
  end
end