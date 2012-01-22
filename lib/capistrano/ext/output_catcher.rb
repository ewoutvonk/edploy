# Copyright (c) 2009-2011 by Ewout Vonk. All rights reserved.

# prevent loading when called by Bundler, only load when called by capistrano
if caller.any? { |callstack_line| callstack_line =~ /^Capfile:/ }
  unless Capistrano::Configuration.respond_to?(:instance)
    abort "capistrano-catch-output requires Capistrano 2"
  end

  require 'stringio'

  module Capistrano
    module OutputCatcher
      class TeeIO

        attr_accessor :sniffed_io_stream, :listening_io_stream

        def initialize(sniffed_io_stream, listening_io_stream)
          self.sniffed_io_stream = sniffed_io_stream
          self.listening_io_stream = listening_io_stream
        end

        def distribute(method_name, *args, &block)
          [ listening_io_stream, sniffed_io_stream ].each do |io_stream|
            io_stream.send(method_name, *args, &block)
          end
        end

        def method_missing(method_name, *args, &block)
          distribute(method_name, *args, &block)
        end

      end
    
      class OutputChannels
      
        attr_accessor :out, :err
      
        def initialize(out, err)
          self.out = out
          self.err = err
        end
      
      end

      module Base
      
        def capture_output(out = StringIO.new, err = nil)
          create_capture_channels(out, err)
          reroute_original_channels
          override_output_channels(out, err)
        end
      
        def tee_output(out = StringIO.new, err = nil)
          create_capture_channels(out, err)
          reroute_original_channels
          override_output_channels(TeeIO.new($std.out, out), TeeIO.new($std.err, err))
        end
      
        def end_capture
          out_output = $capstd.out.string
          err_output = $capstd.err.string
          $capoutput = [ out_output, err_output ]
        end

        private
      
        def override_output_channels(out, err)
          logger.instance_variable_set(:@device, (logger.device == $std.err) ? err : out)
          $stdout = out
          $stderr = err
        end
      
        def create_capture_channels(out = StringIO.new, err = nil)
          err ||= out
          $capstd = OutputChannels.new(out, err)
        end

        def reroute_original_channels
          $std = OutputChannels.new($stdout, $stderr)
        end
      
      end
    end
  end

  Capistrano.plugin :output_catcher, Capistrano::OutputCatcher::Base

  Capistrano::Configuration.instance(:must_exist).load do
    trap("EXIT") do
      output_catcher.end_capture
      if defined?(capistrano_output_handler) == "method"
        capistrano_output_handler
      end
    end
  end

end