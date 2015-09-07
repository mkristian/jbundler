#-*- mode: ruby -*-
p '-' * 80
p ENV['BUNDLE_GEMFILE']
p '-' * 80

ENV['BUNDLE_GEMFILE'] = File.dirname( __FILE__) + "/Gemfile"

require 'jbundler'

JBundler.install
JBundler.setup

raise "missing slf4j-api-1.7.12.jar" unless $CLASSPATH.detect { |c| c =~ %r(slf4j-api-1.7.12) }

# vim: syntax=Ruby
