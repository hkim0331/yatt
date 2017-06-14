#!/usr/bin/env ruby
# coding: utf-8
#
# yatt: yet another typing trainer
# programmed by Hiroshi.Kimura@melt.kyutech.ac.jp
# Copyright (C) 2002-2017 Hiroshi Kimura.
#

system("/edu/bin/xcowsay \"心を落ち着け、起動を待とう。\n戦いの日は近い。\n情セの PC は速くない。\"& ") if File.exists?("/edu/bin/xcowsay")

require 'tk'
require 'drb'

require_relative 'logger'
require_relative 'my-plot'
require_relative 'my-status'
require_relative 'my-text'
require_relative 'scoreboard'
require_relative 'speed-meter'
require_relative 'trainer'

YATT_VERSION = '0.91'
DATE = '2017-06-14'
COPYRIGHT = "programmed by Hiroshi Kimura
version #{YATT_VERSION}(#{DATE})
Copyright (C) 2002-2017.\n"

DRUBY    = "druby://150.69.90.82:23002"
YATT_TXT = "yatt.txt"
YATT_IMG = "yatt*.gif"

GOOD = "green"
BAD  = "red"

RANKER      = 30
TIMEOUT     = 60
TAKE_A_REST = 20
ACCURACY_THRES = 0.5

LIB = [File.join(ENV['HOME'],'Library/yatt'),
    '/edu/lib/yatt','/opt/lib/yatt/','../lib'].select{|x| File.exists?(x)}.first
README       = File.join(LIB, "README")

YATT_DIR     = File.join(ENV['HOME'], '.yatt')
HISTORY      = File.join(YATT_DIR, 'history')
TODAYS_SCORE = File.join(YATT_DIR, Time.now.strftime('%m-%d'))
ACCURACY     = File.join(YATT_DIR, 'accuracy')
MY_FONT      = File.join(YATT_DIR, 'font')

Dir.mkdir(YATT_DIR) unless File.directory?(YATT_DIR)

# stop, 2017-06-14
# def debug(s)
#   STDERR.puts s if ENV['YATT_DEBUG']
# end

def usage(s)
  print <<EOU
unknown arg: #{s}
usage:
  #{$0} [--druby uri] [--lib path]
EOU
  exit(1)
end

# ruby 2.2 Array class does not recognize sum.
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
  when /--version/
    puts YATT_VERSION
    exit(1)
  else
    usage(arg)
  end
end

if ENV['YATT_DEBUG']
  TIMEOUT = 3
  TAKE_A_REST = 2
end

DRb.start_service
remote = DRbObject.new(nil, druby)
Trainer.new(druby, remote, lib)
Tk.mainloop
