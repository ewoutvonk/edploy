# Copyright (c) 2009-2011 by Ewout Vonk. All rights reserved.

module Dployify
  class String
    def self.unindent(string)
      indentation = string[/\A\s*/]
      string.strip.gsub(/^#{indentation}/, "")
    end
  end
end
