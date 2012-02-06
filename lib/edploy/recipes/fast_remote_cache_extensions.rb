namespace :edploy do
  before 'fast_remote_cache:prepare', 'edploy:gc'
  task :gc do
    run "cd #{shared_path}/cached-copy ; git gc"
  end
  
  after 'fast_remote_cache:prepare', 'edploy:pre_bundle'
  task :pre_bundle do
    run "cd #{shared_path}/cached-copy ; bundle install --path #{shared_path}/vendor/bundle --local --without development test || bundle install --path #{shared_path}/vendor/bundle --without development test"
  end
end
