if defined?(REQUIRE_BUNDLE_EXEC) && REQUIRE_BUNDLE_EXEC && (ENV['BUNDLE_GEMFILE'].nil? || ENV['BUNDLE_BIN_PATH'].nil?)
  abort "You should run this with bundle exec!"
elsif !File.exists?(File.join(Dir.getwd, 'Capfile'))
  abort "You should run this from the rails root!"
end

require 'syck'

Syck.load_file(File.expand_path('../../config/deploy.yml', __FILE__)).each do |key, value|
  self.class.const_set(key.to_sym.upcase, value)
end

GEM_DIR = File.expand_path('../../../', __FILE__)
RAILS_ROOT = Dir.getwd
MY_HOSTNAME = `hostname`.strip
MY_HOSTNAME_WITHOUT_INDEX = `hostname | sed 's/[0-9]$//'`.strip

unless defined?(Capistrano::Configuration) # only execute when this file gets included from a normal script
  PROJECT_PATH = ENV['PROJECT_PATH'] || File.expand_path('../../../../', __FILE__)
  DEPLOY_USER = (ENV['DEPLOY_USER'].nil? || ENV['DEPLOY_USER'].empty?) ? `id -un`.strip : ENV['DEPLOY_USER']
  DEPLOY_GROUP = (ENV['DEPLOY_GROUP'].nil? || ENV['DEPLOY_GROUP'].empty?) ? `id -gn`.strip : ENV['DEPLOY_GROUP']

  if %w(staging test qa tryout).include?(MY_HOSTNAME)
    RAILS_ENV = 'staging'
    if MY_HOSTNAME == 'test'
      STAGE = 'testmachine'
    else
      STAGE = MY_HOSTNAME
    end
    SHARED_PATH = "#{DEPLOY_TO}/shared"
    CURRENT_PATH = "#{DEPLOY_TO}/current"
    GLUSTERFS_PATH = "/mnt/glusterfs"
  elsif %w(app db).include?(MY_HOSTNAME_WITHOUT_INDEX)
    RAILS_ENV = 'production'
    STAGE = 'production'
    SHARED_PATH = "#{DEPLOY_TO}/shared"
    CURRENT_PATH = "#{DEPLOY_TO}/current"
    GLUSTERFS_PATH = "/mnt/glusterfs"
  else
    RAILS_ENV = 'development'
    STAGE = nil
    SHARED_PATH = File.expand_path('../../../../shared', __FILE__)
    CURRENT_PATH = PROJECT_PATH
    GLUSTERFS_PATH = File.expand_path('../../../../glusterfs', __FILE__)
  end
end