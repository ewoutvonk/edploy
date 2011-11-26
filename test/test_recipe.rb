# Copyright (c) 2009-2011 by Ewout Vonk. All rights reserved.

require 'test/unit'
require 'dploy/dployify/string'
require 'dploy/dployify/recipe'

class TestRecipe < Test::Unit::TestCase

  TESTINPUT = {
    :domain => "my.tld",
    :nil_value => nil,
    :string_value => "my_string",
    :int_value => 3,
    :float_value => 3.25,
    :code_value => Code("3 + 2"),
    :this_key_is_discarded_only_the_value_is_used => CommentLine("this is a comment line"),
    :commented_int_value => Comment(6),
    :commented_nil_value => Comment(nil),
    :value_with_side_comment => WithSideComment(3.7, 'a value with a comment'),
    :value_with_top_comment => WithTopComment('bla', 'a value with a comment prepended above'),
    "my.app.tld" => Server(:app, :web),
    Code("domain") => Server(:db, :web, :app, :primary => true),
    :indexer => Role("indexer1.my.tld", "indexer2.my.tld", :my_option => 3),
    :mail => Role("mail1.my.tld")
  }
  
  TESTOUTPUT = Dployify::String.unindent(<<-FILE)
    set :domain, "my.tld"
    set :nil_value, nil
    set :string_value, "my_string"
    set :int_value, 3
    set :float_value, 3.25
    set(:code_value) { 3 + 2 }
    # this is a comment line
    # set :commented_int_value, 6
    # set :commented_nil_value, nil
    set :value_with_side_comment, 3.7 # a value with a comment
    # a value with a comment prepended above
    set :value_with_top_comment, "bla"
    server "my.app.tld", :app, :web
    server domain, :db, :web, :app, :primary => true
    role :indexer, "indexer1.my.tld", "indexer2.my.tld", :my_option => 3
    role :mail, "mail1.my.tld"
  FILE

  def test_generate
    files = {}
    filename = "testfile"
    Dployify::Recipe.generate(files, filename, TESTINPUT)
    assert files.has_key?(filename)
    assert_equal TESTOUTPUT.strip.split("\n").sort.join("\n"), files[filename].strip.split("\n").sort.join("\n")
  end

end