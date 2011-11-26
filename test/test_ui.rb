# Copyright (c) 2009-2011 by Ewout Vonk. All rights reserved.

require 'test/unit'
require 'dploy/dployify/ui'

class HighLineMock
  
  attr_accessor :asked_for, :calls
  
  def initialize
    self.asked_for = []
    self.calls = 0
  end
  
  def ask(prompt, &block)
    self.asked_for << prompt.gsub(/: $/, '').upcase
    self.calls += 1
    prompt.gsub(/: $/, '').upcase
  end
  
end

class TestUi < Test::Unit::TestCase

  def setup
    @mock = HighLineMock.new
    Dployify::Ui.ui(@mock)
  end

  def test_ask_setting
    settings = {}
    Dployify::Ui.ask_setting(settings, :application)
    assert_equal "APPLICATION", settings[:application]
    assert_equal 1, @mock.calls
  end

  def test_ask_existing_setting
    settings = { :application => 'bla' }
    Dployify::Ui.ask_setting(settings, :application)
    assert_equal 0, @mock.calls
  end

  def test_ask_setting_with_default
    settings = {}
    Dployify::Ui.ask_setting(settings, :application, 'bla')
    assert_equal "APPLICATION [BLA]", settings[:application]
    assert_equal 1, @mock.calls
  end
  
  def test_ask_settings
    settings = {}
    Dployify::Ui.ask_settings(settings, :application, :repository, :domain)
    assert_equal 3, @mock.calls
    assert (@mock.asked_for - [ "APPLICATION", "REPOSITORY", "DOMAIN" ]).empty?
  end

  def test_ask_settings_with_existing_setting
    settings = { :application => 'bla' }
    Dployify::Ui.ask_settings(settings, :application, :repository, :domain)
    assert_equal 2, @mock.calls
    assert (@mock.asked_for - [ "REPOSITORY", "DOMAIN" ]).empty?
  end
  
end