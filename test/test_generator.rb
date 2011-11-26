# Copyright (c) 2009-2011 by Ewout Vonk. All rights reserved.

require 'test/unit'
require 'dploy/dployify/generator'

class TestGenerator < Test::Unit::TestCase

  def test_dtap_generate_settings
    settings = {}
    Dployify::Generator.generate_settings(:dtap, settings)
    assert settings.has_key?(:stages)
    assert_equal 4, settings[:stages].keys.count
    assert settings[:stages].has_key?(:production)
    assert_equal 4, settings[:stages][:production][:servers].keys.count
  end

  def test_simple_generate_settings
    settings = {}
    Dployify::Generator.generate_settings(:simple, settings)
    assert settings.has_key?(:servers)
    assert_equal 4, settings[:servers].keys.count
  end

  def test_dont_generate_settings
    settings = { :servers => {} }
    Dployify::Generator.generate_settings(:dtap, settings)
    assert_equal 1, settings.keys.count
    assert settings.has_key?(:servers)
    assert settings[:servers].empty?
  end
  
end