# Copyright (c) 2009-2011 by Ewout Vonk. All rights reserved.

require 'test/unit'
require 'dploy/dployify/resolver'

class TestResolver < Test::Unit::TestCase

  TEST_INPUT = {
    :var1 => "var1",
    :var2 => "var2 %%var1%%",
    :level1 => "level1",
    :level2 => "level2 %%level1%%",
    :level3 => "level3 %%level2%%",
    :stages => {
      :staging => {
        :var2 => "2var %%top.var1%%",
        :stage_variable => "%%var2%%"
      }
    }
  }
  
  TEST_OUTPUT = {
    :var1 => "var1",
    :var2 => "var2 var1",
    :level1 => "level1",
    :level2 => "level2 level1",
    :level3 => "level3 level2 level1",
    :stages => {
      :staging => {
        :var2 => "2var var1",
        :stage_variable => "2var var1"
      }
    }
  }

  def test_parse_with_resolve_variables
    settings = TEST_INPUT
    Dployify::Resolver.resolve_variables_in_settings(settings)
    assert_equal TEST_OUTPUT, settings
  end
  
end