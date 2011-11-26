# Copyright (c) 2009-2011 by Ewout Vonk. All rights reserved.

require 'test/unit'
require 'dploy/dployify/settings'

class HighLineMock
  
  def ask(prompt, &block)
    if prompt.gsub(/: $/, '').to_sym == :scm
      "git"
    else
      prompt.gsub(/: $/, '')
    end
  end
  
end

class TestSettings < Test::Unit::TestCase

  TEST_TO_FILES_INPUT = {
    :application => "myapp",
    :stages => {
      :staging => {
        :rails_env => :staging
      },
      :production => {
        :rails_env => :production
      }
    }
  }

  TEST_TO_FILES_OUTPUT = {
    "config/deploy.rb" => Dployify::String.unindent(<<-FILE),
      set :application, "myapp"
    FILE
    "config/deploy/staging.rb" => Dployify::String.unindent(<<-FILE),
      set :rails_env, :staging
    FILE
    "config/deploy/production.rb" => Dployify::String.unindent(<<-FILE),
      set :rails_env, :production
    FILE
  }
  
  def assert_hash_key_pair(hsh, key, value)
    assert hsh.has_key?(key)
    assert_equal value, hsh[key]
  end
    
  def setup
    @mock = HighLineMock.new
    Dployify::Ui.ui(@mock)
  end
  
  def test_parse_with_ask_settings
    Dployify::Settings.set({})
    base_settings = {
      :application => "myapp",
      :repository => "git@my.server.tld:myapp.git",
      :domain => "my.app.tld"
    }
    settings = Dployify::Settings.parse(base_settings)
    assert_hash_key_pair settings, :scm, "git"
  end

  def test_to_files
    files = Dployify::Settings.to_files(TEST_TO_FILES_INPUT)
    TEST_TO_FILES_OUTPUT.each do |filename, contents|
      assert files.has_key?(filename)
      assert_equal contents.strip, files[filename].strip
    end
    assert files.has_key?("config/dploy/recipes.rb")
  end

end