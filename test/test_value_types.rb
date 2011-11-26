# Copyright (c) 2009-2011 by Ewout Vonk. All rights reserved.

require 'test/unit'
require 'dploy/dployify/value_types'

class TestValueTypes < Test::Unit::TestCase
  
  def test_Code
    objekt = Code(3)
    assert_equal Code, objekt.class
    assert_equal 3, objekt.value
  end
  
  def test_Comment
    objekt = Comment("myvalue")
    assert_equal Comment, objekt.class
    assert_equal "myvalue", objekt.value
  end
  
  def test_CommentLine
    objekt = CommentLine("this is a test")
    assert_equal CommentLine, objekt.class
    assert_equal "this is a test", objekt.value
  end
  
  def test_Server
    objekt = Server(:db, :web)
    assert_equal Server, objekt.class
    assert_nothing_thrown do
      assert ([ :web, :db ] - objekt.roles).empty?
    end
  end

  def test_Server_with_options
    objekt = Server(:db, :web, :app, :primary => true)
    assert_equal Server, objekt.class
    assert_nothing_thrown do
      assert ([ :web, :db, :app ] - objekt.roles).empty?
      assert_equal Hash, objekt.options.class
      assert objekt.options.has_key?(:primary)
    end
  end
  
  def test_Role
    objekt = Role("a.tld", "b.tld")
    assert_equal Role, objekt.class
    assert_nothing_thrown do
      assert ([ "b.tld", "a.tld" ] - objekt.hosts).empty?
    end
  end

  def test_Role_with_options
    objekt = Role("a.tld", "b.tld", "c.tld", :primary => true)
    assert_equal Role, objekt.class
    assert_nothing_thrown do
      assert ([ "c.tld", "a.tld", "b.tld" ] - objekt.hosts).empty?
      assert_equal Hash, objekt.options.class
      assert objekt.options.has_key?(:primary)
    end
  end
  
  def test_WithSideComment
    objekt = WithSideComment("myvalue", "my side comment")
    assert_equal WithSideComment, objekt.class
    assert_equal "myvalue", objekt.value
    assert_equal "my side comment", objekt.comment
  end
  
  def test_WithTopComment
    objekt = WithTopComment("myvalue", "my side comment")
    assert_equal WithTopComment, objekt.class
    assert_equal "myvalue", objekt.value
    assert_equal "my side comment", objekt.comment
  end
  
end