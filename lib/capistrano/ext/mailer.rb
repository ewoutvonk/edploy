# Copyright (c) 2009-2011 by Ewout Vonk. All rights reserved.
# Copyright (c) 2009   9thBit LLC   (http://www.9thbit.net)
# Copyright (c) 2007-8 Sagebit, LLC (http://www.sagebit.com)

# prevent loading when called by Bundler, only load when called by capistrano
if caller.any? { |callstack_line| callstack_line =~ /^Capfile:/ }
  unless Capistrano::Configuration.respond_to?(:instance)
    abort "capistrano-mailer requires Capistrano 2"
  end
  
  require 'action_mailer' unless defined?(ActionMailer)
  
  module Capistrano
    module Configuration
      
      class ActionMailer < ActionMailer::Base
        delivery_method = :smtp

        smtp_settings = {
          :address              => 'localhost',
          :port                 => 25,
          :enable_starttls_auto => false
        }

        default :charset => 'utf-8'

        def notify(textbody, options, mail_attachments)
          mail_attachments.each do |filename, contents|
            if File.exists?(filename.to_s)
              attachments[File.basename(filename.to_s)] = File.read(filename.to_s)
            elsif File.exists?(contents.to_s)
              attachments[File.basename(contents.to_s)] = File.read(contents.to_s)
            else
              attachments[File.basename(filename.to_s)] = contents
            end
          end
          mail(options) do |format|
            format.text { render :text => textbody }
          end
        end        
      end
      
      class Mailer
        
        def send(sender, recipients, subject, text_body, cc = nil, bcc = nil, attachments = {})
          configure
          options = {
            :from => sender,
            :to => recipients,
            :subject => subject,
            :cc => cc,
            :bcc => bcc
          }
          Capistrano::Configuration::ActionMailer.notify(textbody, options, attachments).deliver
        end

        private
        
        def configure
          return if @configured
          if (fetch(:mailer_address, nil) || fetch(:mailer_port, nil) || fetch(:mailer_domain, nil))
            Capistrano::Configuration::ActionMailer.delivery_method = :smtp
            Capistrano::Configuration::ActionMailer.smtp_settings = {
              :address              => fetch(:mailer_address, 'localhost'),
              :port                 => fetch(:mailer_port, 25),
              :domain               => fetch(:mailer_domain, nil), # example: "default.com"
              :user_name            => fetch(:mailer_user_name, nil), # example: "releases@example.com"
              :password             => fetch(:mailer_password, nil), # example: "mypassword"
              :authentication       => fetch(:mailer_authentication, nil), # example: :login
              :openssl_verify_mode  => fetch(:mailer_openssl_verify_mode, nil),
              :enable_starttls_auto => fetch(:mailer_enable_starttls_auto, false)
            }
          elsif (location = fetch(:mailer_location, nil))
            Capistrano::Configuration::ActionMailer.delivery_method = :sendmail
            Capistrano::Configuration::ActionMailer.sendmail_settings = {
              :location             => location, 
              :arguments            => fetch(:mailer_arguments, nil)
            }
          end
          Capistrano::Configuration::ActionMailer.default :charset => fetch(:mailer_default_charset, 'utf-8')
          @configured = true
        end
                
      end
    end
  end
  
  Capistrano.plugin :mailer, Capistrano::Configuration::Mailer

end