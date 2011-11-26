# Copyright (c) 2009-2011 by Ewout Vonk. All rights reserved.

require 'test/unit'
require 'dploy/dployify/file_utils'
require 'fileutils'

class TestFileUtils < Test::Unit::TestCase

  def redirect_stdout
    $orig_stdout, $stdout = [ $stdout, (io = StringIO.new("", "a+")) ]
    yield
    $stdout = $orig_stdout
    io.string
  end

  def redirect_stderr
    $orig_stderr, $stderr = [ $stderr, (io = StringIO.new("", "a+")) ]
    yield
    $stderr = $orig_stderr
    io.string
  end
  
  def redirect
    value = nil
    @error_output = redirect_stderr do
      @output = redirect_stdout do
        value = yield
      end
    end
    value
  end
  
  def generate_call(base_dir)
    files = {
      'config/deploy/staging.rb' => "STAGING",
      'config/deploy/production.rb' => "PRODUCTION",
      'config/deploy.rb' => "DEPLOY"
    }
    redirect do
      Dployify::FileUtils.generate(base_dir, files)
    end
    if File.directory?(base_dir)
      files.map { |file, contents| [ File.join(base_dir, file), contents ] }.each do |file_hash|
        file = file_hash.first
        contents = file_hash.last
        assert File.directory?(File.dirname(file))
        assert File.exists?(file)
        assert_equal contents, File.read(file)
        FileUtils.rm_f(file)
      end
      files.map { |file, contents| File.dirname(File.join(base_dir, file)) }.uniq.each do |dir|
        Dir.rmdir(dir)
      end
      Dir.rmdir(base_dir)
      Dir.rmdir(File.dirname(base_dir))
    else
      assert (@error_output.strip =~ /does not exist/)
    end
  end

  def test_generate
    base_dir = File.expand_path('../../tmp/test_file_utils_files', __FILE__)
    FileUtils.mkdir_p(File.join(base_dir, 'config'))
    generate_call(base_dir)
  end
  
  def test_generate_with_non_existing_dir
    base_dir = File.expand_path('../../tmp/test_file_utils_files', __FILE__)
    generate_call(base_dir)
  end

end