#-*- mode: ruby -*-

require 'fileutils'
require 'jbundler'

args = [ false, false, { :vendor_dir => 'jars' }]

def ensure_install
  raise "missing Jars.lock" unless File.exists?( 'Jars.lock' )
  raise "missing jars directory" unless File.exists?( 'jars/com' )
end

def ensure_no_update( lock_time, jar_time )
  raise "unexpected update of Jars.lock" if File.mtime( 'Jars.lock' ) != lock_time
  raise "unexpected update of jars" if File.mtime( 'jars/com/fasterxml/jackson/core/jackson-core/2.3.0/jackson-core-2.3.0.jar' ) != jar_time
end

FileUtils.rm_rf( 'Jars.lock' )
FileUtils.rm_rf( 'jars' )

JBundler.install( *args )

ensure_install

FileUtils.rm_rf( 'jars' )

JBundler.install( *args )

lock_time = File.mtime( 'Jars.lock' )
jar_time = File.mtime( 'jars/com/fasterxml/jackson/core/jackson-core/2.3.0/jackson-core-2.3.0.jar' )

FileUtils.touch( 'Gemfile', :mtime => 222212311800 )

JBundler.install( *args )

ensure_no_update( lock_time, jar_time )

FileUtils.touch( 'Gemfile.lock', :mtime => 222212311800 )

JBundler.install( *args )

ensure_no_update( lock_time, jar_time )

FileUtils.touch( 'Jarfile', :mtime => 222212311800 )

JBundler.install( *args )

ensure_no_update( lock_time, jar_time )

FileUtils.touch( 'Jars.lock', :mtime => 222212311800 )

# use the updated timestamp
lock_time = File.mtime( 'Jars.lock' )

JBundler.install( *args )

ensure_no_update( lock_time, jar_time )

# vim: syntax=Ruby
