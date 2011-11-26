# Copyright (c) 2009-2011 by Ewout Vonk. All rights reserved.

require File.expand_path('../recipe', __FILE__)
require File.expand_path('../ui', __FILE__)
require File.expand_path('../string', __FILE__)
require File.expand_path('../transformer', __FILE__)
require File.expand_path('../resolver', __FILE__)
require File.expand_path('../generator', __FILE__)

DEFAULT_FILES = {
  "config/dploy/recipes.rb" => Dployify::String.unindent(<<-FILE),
    default_run_options[:pty] = true
    require 'dploy'
  FILE
}

module Dployify
  class Settings
    
    class << self
      
      def dployify_settings
        @@dployify_settings || {}
      end
      
      def set(settings = nil, &block)
        if settings
          @@dployify_settings = settings
        elsif block_given?
          @@dployify_settings = yield
        end
      end
      
      def parse(base_settings = {})
        settings = base_settings.merge(dployify_settings)
        ask_settings(settings)
        Dployify::Generator.generate_settings(settings[:app_lifecycle] ? settings.delete(:app_lifecycle) : :simple, settings)
        Dployify::Transformer.transform_settings(settings)
        Dployify::Resolver.resolve_variables_in_settings(settings)
        settings
      end
      
      def to_files(settings)
        files = {}
        stages = settings[:stages] ? settings.delete(:stages) : {}
        Dployify::Recipe.generate(files, 'config/deploy.rb', settings)
        stages.each do |stage_name, stage_settings|
          Dployify::Recipe.generate(files, "config/deploy/#{stage_name}.rb", stage_settings)
        end
        files.merge(DEFAULT_FILES)
      end
      
      private
      
      def ask_settings(settings)
        Dployify::Ui.ask_settings(settings, :application, :domain, :scm, :repository)
        if settings[:repository] && settings[:repository] =~ /%%reponame%%/
          Dployify::Ui.ask_setting(settings, :reponame, settings[:application])
        end
        Dployify::Ui.ask_settings(settings, :dbserver, :webserver, :appserver, :framework)
      end
            
    end
    
  end
end