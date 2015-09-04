#-*- mode: ruby -*-

Gem.install( File.expand_path( "../../gem/pkg/first-1.1.1.gem", __FILE__ ) )

require 'jbundler'

JBundler.install( true )
JBundler.setup

raise "missing tools.jar" unless $CLASSPATH.detect { |c| c =~ /tools.jar/ }
raise "found unexpected jruby-core-1.7.20.jar" if $CLASSPATH.detect { |c| c =~ /jruby-core-1.7.20.jar/ }

# vim: syntax=Ruby
