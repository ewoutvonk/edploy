# Copyright (c) 2009-2011 by Ewout Vonk. All rights reserved.

class Literal
  attr_accessor :value
  def initialize(value)
    self.value = value
  end
end

class Code < Literal
end

class Comment < Literal
end

class CommentLine < Literal
end

class Server
  attr_accessor :roles, :options
  def initialize(*args)
    self.options = args.last.is_a?(Hash) ? args.pop : {}
    self.roles = args
  end
end

class Role
  attr_accessor :hosts, :options
  def initialize(*args)
    self.options = args.last.is_a?(Hash) ? args.pop : {}
    self.hosts = args
  end
end

class Commented
  attr_accessor :value, :comment
  def initialize(value, comment)
    self.value = value
    self.comment = comment
  end
end

class WithSideComment < Commented ; end
class WithTopComment < Commented ; end

def Code(value)
  Code.new(value)
end

def Comment(value)
  Comment.new(value)
end

def CommentLine(value)
  CommentLine.new(value)
end

def Server(*args)
  Server.new(*args)
end

def Role(*args)
  Role.new(*args)
end

def WithSideComment(value, comment)
  WithSideComment.new(value, comment)
end

def WithTopComment(value, comment)
  WithTopComment.new(value, comment)
end