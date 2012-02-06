# Copyright (c) 2009-2012 by Ewout Vonk. All rights reserved.

# prevent loading when called by Bundler, only load when called by capistrano
if caller.any? { |callstack_line| callstack_line =~ /^Capfile:/ }
  unless Capistrano::Configuration.respond_to?(:instance)
    abort "edploy requires Capistrano 2"
  end

  Capistrano::Configuration.instance(:must_exist).load do
    load File.expand_path('../edploy/environment_capistrano.rb', __FILE__)
  	load File.expand_path('../capistrano/ext/multistage.rb', __FILE__)
  	# load File.expand_path('../capistrano/ext/mailer.rb', __FILE__)
    # load File.expand_path('../capistrano/ext/output_catcher.rb', __FILE__)
    # load File.expand_path('../capistrano/ext/output_hooks.rb', __FILE__)
  	Dir[File.expand_path('../edploy/recipes/*.rb', __FILE__)].each { |plugin| load(plugin) }
  end
end
