#-*- mode: ruby -*-

require 'jbundler'

JBundler.install
JBundler.setup

raise "missing kafka_2.10-0.8.1.1.jar" unless $CLASSPATH.detect { |c| c =~ %r(/org/apache/kafka/kafka_2.10/0.8.1.1/kafka_2.10-0.8.1.1.jar) }

# vim: syntax=Ruby
