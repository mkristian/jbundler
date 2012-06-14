require 'rubygems'
require 'bundler'
Bundler.require

puts <<-INFO
classpath:
#{JBUNDLER_CLASSPATH.join("\n")}
INFO
