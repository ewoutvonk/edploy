# Copyright (c) 2009-2011 by Ewout Vonk. All rights reserved.

require File.expand_path('../arguments', __FILE__)
require File.expand_path('../settings', __FILE__)
require File.expand_path('../file_utils', __FILE__)

module Dployify
  class Cli
    
    def initialize(argv)
      base, base_settings = Dployify::Arguments.parse(argv.dup)
      puts "First we run `capify #{base}'"
      system("capify #{base}")
      require File.expand_path('./config/boot', base)
      require File.expand_path('./config/environment', base)
      settings = Dployify::Settings.parse(base_settings)
      files = Dployify::Settings.to_files(settings)
      Dployify::FileUtils.generate(base, files)
      puts "[done] dployified!"
    end
    
  end
end

