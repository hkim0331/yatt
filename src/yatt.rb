#!/usr/bin/env ruby
# coding: utf-8
#
# yatt: yet another typing trainer
# programmed by Hiroshi.Kimura@melt.kyutech.ac.jp
# Copyright (C) 2002-2017 Hiroshi Kimura.
#

require 'tk'
require 'drb'

require_relative 'logger'
require_relative 'my-plot'
require_relative 'my-status'
require_relative 'my-text'
require_relative 'scoreboard'
require_relative 'speed-meter'
require_relative 'trainer'

$debug = false

YATT_VERSION = '0.73'
DATE = ''
COPYRIGHT = "programmed by Hiroshi Kimura
version #{YATT_VERSION}(#{DATE})
Copyright (C) 2002-2017.\n"

DRUBY      = "druby://150.69.90.82:23002"
YATT_TXT   = "yatt.txt"
YATT_IMG   = "yatt4.gif"

GOOD = "green"
BAD  = "red"

RANKER     = 30

if $debug
  TIMEOUT = 10
else
  TIMEOUT = 60
end

if File.exists?(File.join(ENV['HOME'], 'Library/yatt'))
  LIB = File.join(ENV['HOME'], 'Library/yatt')
elsif File.exists?('/edu/lib/yatt')
  LIB = '/edu/lib/yatt'
elsif File.exists?('/opt/lib/yatt')
  LIB = '/opt/lib/yatt'
elsif File.exists?('../lib')
  LIB = '../lib'
end

README       = File.join(LIB, "README")
YATT_DIR     = File.join(ENV['HOME'], '.yatt')
Dir.mkdir(YATT_DIR) unless File.directory?(YATT_DIR)
HISTORY      = File.join(YATT_DIR, 'history')
TODAYS_SCORE = File.join(YATT_DIR, Time.now.strftime('%m-%d'))
ACCURACY     = File.join(YATT_DIR, 'accuracy')
MY_FONT      = File.join(YATT_DIR, 'font')

def debug(s)
  STDERR.puts s if $debug
end

def usage(s)
  print <<EOU
unknown arg: #{s}
usage:
  #{$0} [--noserver|--server server] [--port port] [--lib path]
EOU
  exit(1)
end

# ruby 2.2.6 Array does not recognize sum.
begin
  [1,2,3].sum
rescue
  module Summable
    def sum
      inject(:+)
    end
  end

  class Array
    include Summable
  end
end

#
# main starts here.
#
druby = DRUBY
lib   = LIB
while (arg = ARGV.shift)
  case arg
  when /--druby/
    druby = ARGV.shift
  when /--lib/
    lib = ARGV.shift
  when /--debug/
    $debug = true
  else
    usage(arg)
  end
end
Trainer.new(druby, lib)
Tk.mainloop
