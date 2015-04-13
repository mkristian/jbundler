#-*- mode: ruby -*-

ENV['BUNDLE_GEMFILE'] = File.dirname( __FILE__) + "/Gemfile"

require 'jbundler'
JBundler.install
Jars.require_jars_lock!

raise "missing kafka_2.10-0.8.2-beta.jar" unless $CLASSPATH.detect { |c| c =~ %r(/org/apache/kafka/kafka_2.10/0.8.2-beta/kafka_2.10-0.8.2-beta.jar) }

raise "missing myfirst.jar" unless $CLASSPATH.detect { |c| c =~ %r(/myfirst.jar) }
# vim: syntax=Ruby
