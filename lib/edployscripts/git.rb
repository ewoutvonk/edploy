module Edploy
	class Git
		
		class << self
			
			def git(*opts)
			  options = opts.last.is_a?(Hash) ? opts.pop : {}
			  opts << "--hard" if options[:hard]
			  if message = options.delete(:message)
			    opts << "-m '#{message}'"
			  end
			  opts << '2>/dev/null' if options[:silent]
			  cmd = "git #{opts.map(&:to_s).join(' ')}"
			  unless system(cmd)
			    return if options[:silent]
			    abort "error while running `#{cmd}'"
			  end
			end
			
			def method_missing(method, *args, &block)
				git(*([method] + args))
			end
			
		end
		
	end
end