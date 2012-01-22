# Copyright (c) 2009-2012 by Ewout Vonk. All rights reserved.

# prevent loading when called by Bundler, only load when called by capistrano
if caller.any? { |callstack_line| callstack_line =~ /^Capfile:/ }
	load File.expand_path('../capistrano/ext/multistage.rb', __FILE__)
	load File.expand_path('../capistrano/ext/mailer.rb', __FILE__)
	load File.expand_path('../dploy/environment_capistrano.rb', __FILE__)
	Dir[File.expand_path('../dploy/recipes/*.rb', __FILE__)].each { |plugin| load(plugin) }
end
