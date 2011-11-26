# Copyright (c) 2009-2011 by Ewout Vonk. All rights reserved.

require 'test/unit'
require 'dploy/dployify/arguments'

class TestArguments < Test::Unit::TestCase

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
  
  def catch_exit
    value = nil
    begin
      value = yield
      assert false
    rescue MiniTest::Assertion => e
      raise e
    rescue SystemExit => e
      @klass = SystemExit
      @exit_status = e.status
    rescue Exception => e
      @klass = e.class
      @exit_status = nil
    end
    value
  end
  
  def redirect_with_catch_exit
    value = nil
    redirect do
      catch_exit do
        value = yield
      end
    end
    value
  end
  
  def parse(*args)
    Dployify::Arguments.parse([args].flatten)
  end
  
  def verify_status_and_output(argv, status, output_regex, error_regex)
    redirect_with_catch_exit do
      parse(argv)
    end
    assert_equal SystemExit, @klass
    assert_equal status, @exit_status
    assert (@output =~ output_regex)
    assert (@error_output =~ error_regex)
  end

  def test_help_availability
    verify_status_and_output([ '--help' ], 0, /^Usage: /, /^$/)
  end
  
  def test_help_on_no_arguments
    verify_status_and_output([], 0, /^Usage: /, /^$/)
  end

  def test_help_after_wrong_argument
    verify_status_and_output([ '--thisiswrong' ], 1, /^Usage: /, /^invalid option:/)
  end
  
  def test_error_on_more_than_one_argument
    redirect_with_catch_exit do
      parse('.', '123')
    end
    assert_equal SystemExit, @klass
    assert_equal 1, @exit_status
    assert (@output =~ /^$/)
    assert (@error_output =~ /^Too many arguments/)
  end

  def test_error_on_non_existing_dir_as_argument
    redirect_with_catch_exit do
      parse('/non-existent')
    end
    assert_equal SystemExit, @klass
    assert_equal 1, @exit_status
    assert (@output =~ /^$/)
    assert (@error_output.strip =~ / does not exist.$/)
  end

  def test_error_on_file_as_argument
    redirect_with_catch_exit do
      parse($0)
    end
    assert_equal SystemExit, @klass
    assert_equal 1, @exit_status
    assert (@output =~ /^$/)
    assert (@error_output.strip =~ / is not a directory.$/)
  end
  
  def test_correct_arguments
    output = redirect do
      parse('-a', 'myapp', '--repository=URL', '--domain', 'bla.tld', '-s', 'git', '/tmp')
    end
    assert "/tmp", output.first
    assert 'myapp', output.last[:application]
    assert 'URL', output.last[:repository]
    assert 'bla.tld', output.last[:domain]
    assert 'git', output.last[:scm]
  end

end