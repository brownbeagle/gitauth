#--
#   Copyright (C) 2009 Brown Beagle Software
#   Copyright (C) 2009 Nokia Corporation and/or its subsidiary(-ies)
#   Copyright (C) 2007, 2008 Johan Sørensen <johan@johansorensen.com>
#   Copyright (C) 2008 Tim Dysinger <tim@dysinger.net>
#   Copyright (C) 2008 Tor Arne Vestbø <tavestbo@trolltech.com>
#   Copyright (C) 2008 Darcy Laycock <sutto@sutto.net>
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Affero General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Affero General Public License for more details.
#
#   You should have received a copy of the GNU Affero General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#++

# This along with the associated gitauth-shell command are inspired by
# (and essentially, derived from) gitosis (http://eagain.net/gitweb/?p=gitosis.git)
# and gitorius (http://gitorius.org)
# Gitosis is of this writing licensed under the GPLv2 and is copyright (c) Tommi Virtanen
# and can be found at http://eagain.net/gitweb/?p=gitosis.git
# GitAuth::Command is licensed under the same license

module GitAuth
  class Command
    class BadCommandError < StandardError; end
    
    # Standard Commands
    READ_COMMANDS  = ["git-upload-pack", "git upload-pack"]
    WRITE_COMMANDS = ["git-receive-pack", "git receive-pack"]
    PATH_REGEXP    = /^'([\w\_\-\.\+]+(\.git)?)'$/i.freeze
    
    attr_reader :path, :verb, :command
    
    def initialize(command)
      @command     = command
      @verb        = nil
      @argument    = nil
      @path        = nil
      @bad_command = true
    end
    
    def bad?
      !!@bad_command
    end
    
    def write?
      !bad? && @verb_type == :write
    end
    
    def read?
      !bad? && !write?
    end
    
    # These exceptions are FUGLY.
    # Clean up, mmkay?
    def process!
      raise BadCommandError if @command.include?("\n")
      raise BadCommandError if @command !~ /^git/i
      @verb, @argument = split_command
      raise BadCommandError if @argument.nil? || @argument.is_a?(Array) 
      # Check if it's read / write
      if READ_COMMANDS.include?(@verb)
        @verb_type = :read
      elsif WRITE_COMMANDS.include?(@verb)
        @verb_type = :write
      else
        raise BadCommandError
      end
      if PATH_REGEXP =~ @argument
        @path = $1
        raise BadCommandError unless @path
      else
        raise BadCommandError
      end
      @bad_command = false
    rescue BadCommandError
    end
    
    def self.parse!(command)
      command = self.new(command)
      command.process!
      command
    end
    
    protected
    
    def split_command
      parts = @command.split(" ")
      if parts.size == 3
        ["#{parts[0]} #{parts[1]}", parts[2]]
      elsif parts.size == 2
        parts
      else
        raise BadCommandError
      end
    end
    
  end
end