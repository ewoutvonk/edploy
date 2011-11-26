# Copyright (c) 2009-2011 by Ewout Vonk. All rights reserved.

require File.expand_path('../value_types', __FILE__)

module Dployify
  class Recipe
    
    class << self
      
      def generate(hsh, filename, settings)
        hsh[filename] = generate_file(settings)
      end
      
      private
      
      def generate_file(settings)
        settings.map { |key, value|
          generate_line(key, value)
        }.join("\n") + "\n"
      end
      
      def generate_line(key, value, prefix = nil, suffix = nil)
        if value.is_a?(CommentLine)
          "# #{value.value}"
        elsif value.is_a?(Comment)
          generate_line(key, value.value, "# ")
        elsif value.is_a?(WithSideComment)
          generate_line(key, value.value, prefix, " # #{value.comment}")
        elsif value.is_a?(WithTopComment)
          "#{generate_line(key, CommentLine(value.comment))}\n#{generate_line(key, value.value)}"
        elsif value.is_a?(Code)
          "#{prefix}set(:#{key}) { #{generate_value(value)} }#{suffix}"
        elsif value.is_a?(Server)
          options_string = value.options.empty? ? "" : ", " + value.options.to_s[1..-2].gsub(/\=>/, ' => ')
          roles_string = value.roles.to_s[1..-2]
          "#{prefix}server #{generate_value(key)}, #{roles_string}#{options_string}"
        elsif value.is_a?(Role)
          options_string = value.options.empty? ? "" : ", " + value.options.to_s[1..-2].gsub(/\=>/, ' => ')
          hosts_string = value.hosts.to_s[1..-2]
          "#{prefix}role #{generate_value(key)}, #{hosts_string}#{options_string}"
        else
          "#{prefix}set :#{key}, #{generate_value(value)}#{suffix}"
        end
      end
      
      def generate_value(value)
        if value.is_a?(Code)
          value.value
        elsif value.nil?
          "nil"
        else
          [ value ].to_s[1..-2]
        end
      end
      
    end
    
  end
end
