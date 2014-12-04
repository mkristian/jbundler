#-*- mode: ruby -*-

require 'jbundler'

JBundler.install
JBundler.setup

raise "missing kafka_2.10-0.8.2-beta.jar" unless $CLASSPATH.detect { |c| c =~ %r(/org/apache/kafka/kafka_2.10/0.8.2-beta/kafka_2.10-0.8.2-beta.jar) }

# vim: syntax=Ruby
