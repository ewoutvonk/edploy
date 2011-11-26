# Copyright (c) 2009-2011 by Ewout Vonk. All rights reserved.

require 'test/unit'
require 'dploy/dployify/string'

class TestString < Test::Unit::TestCase

  TEST_STRING = <<-FILE
    default_run_options[:pty] = true
    require 'dploy'
  FILE

  TEST_UNINDENTED_STRING = Dployify::String.unindent(<<-FILE)
    default_run_options[:pty] = true
    require 'dploy'
  FILE
  
  EXPECTED_STRING = <<-FILE
default_run_options[:pty] = true
require 'dploy'
  FILE

  def test_unindent
    assert_equal EXPECTED_STRING.strip, TEST_UNINDENTED_STRING
    assert_equal EXPECTED_STRING.strip, Dployify::String.unindent(TEST_STRING)
  end

end