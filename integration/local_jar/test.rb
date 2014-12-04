#-*- mode: ruby -*-

require 'jbundler'

JBundler.install
JBundler.setup

raise "missing myfirst.jar" unless $CLASSPATH.detect { |c| c =~ %r(/myfirst.jar) }

# vim: syntax=Ruby
