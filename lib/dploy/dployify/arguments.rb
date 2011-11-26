# Copyright (c) 2009-2011 by Ewout Vonk. All rights reserved.

require 'optparse'

module Dployify
  class Arguments
    
    class << self
      
      def parse(argv)
        base_settings = {}

        if argv.empty?
          argv << "-h"
        end
        
        options = OptionParser.new do |opts|
          opts.banner = "Usage: #{File.basename($0)} [path]\n  where 'path' is the directory to depify, e.g. `#{File.basename($0)} .'"

          opts.on("-h", "--help", "Displays this help info") do
            puts opts
            exit 0
          end

          opts.on("-a", "--application APPLICATION_NAME", "Name of the application") do |value|
            base_settings[:application] = value
          end

          opts.on("-r", "--repository REPOSITORY", "Full URL of the repository") do |value|
            base_settings[:repository] = value
          end

          opts.on("-d", "--domain DOMAIN", "Domain name of the application") do |value|
            base_settings[:domain] = value
          end

          opts.on("-s", "--scm SCM", "SCM") do |value|
            base_settings[:scm] = value
          end

          opts.on("-F", "--framework FRAMEWORK", "Framework to use") do |value|
            base_settings[:framework] = value
          end

          opts.on("-D", "--dbserver DBSERVER", "Database server to use") do |value|
            base_settings[:dbserver] = value
          end

          opts.on("-W", "--webserver WEBSERVER", "Web server to use") do |value|
            base_settings[:webserver] = value
          end

          opts.on("-A", "--appserver APPSERVER", "Application server to use") do |value|
            base_settings[:appserver] = value
          end

          begin
            opts.parse!(argv)
          rescue OptionParser::ParseError => e
            warn e.message
            puts opts
            exit 1
          end
        end

        if !File.exists?(argv.first)
          abort "`#{argv.first}' does not exist."
        elsif !File.directory?(argv.first)
          abort "`#{argv.first}' is not a directory."
        elsif argv.length > 1
          abort "Too many arguments; please specify only the directory to dployify."
        end
        
        [ argv.first, base_settings ]
      end
      
    end
    
  end
end