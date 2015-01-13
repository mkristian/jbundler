#-*- mode: ruby -*-

require 'fileutils'
require 'jbundler'

def ensure_install
  raise "missing Jarfile.lock" unless File.exists?( 'Jarfile.lock' )
  raise "missing .jbundler" unless File.exists?( '.jbundler/classpath.rb' )
end

def ensure_no_update( lock_time, classpath_time )
  raise "unexpected update of Jarfile.lock" if File.mtime( 'Jarfile.lock' ) != lock_time
  raise "unexpected update of .jbundler/classpath.rb" if File.mtime( '.jbundler/classpath.rb' ) != classpath_time

end

FileUtils.rm_rf( 'Jarfile.lock' )
FileUtils.rm_rf( '.jbundler' )

JBundler.install

ensure_install

FileUtils.rm_rf( '.jbundler' )

JBundler.install

require './.jbundler/classpath.rb'

$CLASSPATH.each do |jar|
  raise "found bouncy-castle #{jar}" if jar =~ /bouncycastle/
end

# vim: syntax=Ruby
