#!/usr/bin/env ruby
#-*- coding: utf-8 -*-
# programmed by Hiroshi Kimura, 2012-04-03.

ARGF.each do |line|
  next if line =~ /^\s*$/
  puts line.strip
end
