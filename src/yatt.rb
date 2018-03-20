#!/usr/bin/env ruby
# coding: utf-8
#
# yatt: yet another typing trainer
# programmed by Hiroshi.Kimura@melt.kyutech.ac.jp
# Copyright (C) 2002-2018 Hiroshi Kimura.
#

if File.exists?("/edu/bin/xcowsay")
  system("/edu/bin/xcowsay --time=8 \"心を落ち着け、起動を待とう。\n戦いの日は近い。\n情セの PC は速くない。\"& ")
end

require 'tk'
# thanks https://stackoverflow.com/questions/43011258/ruby-tks-canvas-and-shapes-are-bugging-out
module TkItemConfigOptkeys
    def itemconfig_hash_kv(id, keys, enc_mode = [], conf = [])
        hash_kv(__conv_item_keyonly_opts(id, keys), enc_mode, conf)
    end
end
require 'drb'

require_relative 'yatt_logger'
require_relative 'scoreboard'
require_relative 'speed-meter'
require_relative 'trainer'
require_relative 'yatt-plot'
require_relative 'yatt-status'
require_relative 'yatt-text'

YATT_VERSION = '1.1.1'
DATE = '2018-03-20'
COPYRIGHT = "programmed by Hiroshi Kimura
version #{YATT_VERSION}(#{DATE})
Copyright (C) 2002-2018.\n"

DRUBY    = "druby://150.69.90.3:4001"
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

def usage(s)
  print <<EOU
unknown arg: #{s}
usage:
  #{$0} [--druby uri] [--lib path]
EOU
  exit(1)
end

# ruby 2.2 Array class does not recognize sum.
# [].sum throw exception.
begin
  [1,2,3].sum
  [].sum
rescue
  module Summable
    def sum
      if self.empty?
        0
      else
        inject(:+)
      end
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
  when /--debug/
    druby = 'druby://127.0.0.1:4001'
    TIMEOUT = 3
    TAKE_A_REST = 2
  else
    usage(arg)
  end
end

DRb.start_service
remote = DRbObject.new(nil, druby)
Trainer.new(druby, remote, lib)
Tk.mainloop
