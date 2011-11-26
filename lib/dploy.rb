# Copyright (c) 2009-2011 by Ewout Vonk. All rights reserved.

# prevent loading when called by Bundler, only load when called by capistrano
if caller.any? { |callstack_line| callstack_line =~ /^Capfile:/ }
  all_capistrano_extensions = [
    "capistrano-deployment-tasks",
    "capistrano-minimal-output",
    "capistrano-multistage",
    "capistrano-optimized-git-deploy",
    "capistrano-smart-deploy",
    "capistrano-stacks"
  ]
  load_capistrano_extensions = []

  if defined?(EXCLUDE_CAPISTRANO_EXTENSIONS)
    load_capistrano_extensions += all_capistrano_extensions.reject { |ext| EXCLUDE_CAPISTRANO_EXTENSIONS.include?(ext.to_sym) }
  elsif defined?(INCLUDE_CAPISTRANO_EXTENSIONS)
    load_capistrano_extensions += all_capistrano_extensions.select { |ext| INCLUDE_CAPISTRANO_EXTENSIONS.include?(ext.to_sym) }
  else
    load_capistrano_extensions += all_capistrano_extensions
  end

  load_capistrano_extensions.each do |ext|
    require "#{ext}"
  end
end