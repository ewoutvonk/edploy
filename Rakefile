require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new do |t|
 t.libs << 'test'
 t.name = "dployify:helpers".to_sym
 t.test_files = [ :string, :file_utils, :value_types, :ui, :arguments ].map { |name| "test/test_#{name.to_s}.rb" }
end

Rake::TestTask.new do |t|
 t.libs << 'test'
 t.name = "dployify:core".to_sym
 t.test_files = [ :recipe, :settings, :generator, :transformer, :resolver ].map { |name| "test/test_#{name.to_s}.rb" }
end

desc "Run tests for dployify"
task :dployify => [ :"dployify:helpers", :"dployify:core" ]

desc "Run tests"
task :test => [ :dployify ]

desc "Run tests"
task :default => :test