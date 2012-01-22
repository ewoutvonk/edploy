# Copyright (c) 2009-2011 by Ewout Vonk. All rights reserved.

# prevent loading when called by Bundler, only load when called by capistrano
if caller.any? { |callstack_line| callstack_line =~ /^Capfile:/ }
  unless Capistrano::Configuration.respond_to?(:instance)
    abort "capistrano-minimal-output requires Capistrano 2"
  end

  require "capistrano-catch-output"
  require "capistrano-mailer"

  Capistrano::Configuration.instance(:must_exist).load do

    output_catcher.capture_output

    task :capistrano_output_handler do
      email_body = $capistrano_out.string
      email_subject = "capistrano output"
      mailer.send(fetch(:mail_sender), fetch(:mail_recipients), email_subject, email_body)
    end

    namespace :capistrano_catch_output do
    
      namespace :handlers do
      
        namespace :on do
          task :bundle_install do
            puts "-----> Gemfile detected, running Bundler version X.Y.Z"
          end
        end
      
        namespace :before do
          task :bundle_install do
            output_catcher.tee_output
          end
        end
      
        namespace :after do
          task :bundle_install do
            output_catcher.capture_output
          end
        end
      
      end
    
    end
  
    before 'bundle:install', 'capistrano_catch_output:handlers:before:bundle_install'
    after 'bundle:install', 'capistrano_catch_output:handlers:after:bundle_install'
    on 'bundle:install', 'capistrano_catch_output:handlers:on:bundle_install'

  end

end