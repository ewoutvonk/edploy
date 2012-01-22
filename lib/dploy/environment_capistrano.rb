if ENV['BUNDLE_GEMFILE'].nil? || ENV['BUNDLE_BIN_PATH'].nil?
  abort "You should run this with bundle exec!"
elsif !File.exists?(File.join(Dir.getwd, 'Capfile'))
  abort "You should run this from the rails root!"
	RAILS_ROOT = Dir.getwd
end

require 'Syck'

Syck.load_file(File.expand_path('../../config/deploy.yml', __FILE__)).each do |key, value|
  if key.to_sym == :ssh_options
    value.each do |ssh_option, value|
      ssh_options[ssh_option.to_sym] = value
    end
  else
    set key.to_sym, value
  end
end