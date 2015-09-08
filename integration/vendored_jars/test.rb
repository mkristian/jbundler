#-*- mode: ruby -*-

$LOAD_PATH.unshift File.expand_path( '../vendor/jars', __FILE__ )
ENV_JAVA['jars.lock'] = File.expand_path( '../vendor/jars/Jars.lock', __FILE__ )
ENV_JAVA['jars.home'] = File.expand_path( '../vendor/jars', __FILE__ )
require 'jars/setup'

raise "missing netty-all-4.0.28.Final.jar" unless $CLASSPATH.detect { |c| c =~ %r(/io/netty/netty-all/4.0.28.Final/netty-all-4.0.28.Final.jar) }
raise "found unexpected jruby-complete-1.7.22.jar" if $CLASSPATH.detect { |c| c =~ /jruby-complete/ }

# vim: syntax=Ruby
