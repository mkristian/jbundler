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

lock_time = File.mtime( 'Jarfile.lock' )
classpath_time = File.mtime( '.jbundler/classpath.rb' )

FileUtils.touch( 'Gemfile', :mtime => 222212311800 )

JBundler.install

ensure_no_update( lock_time, classpath_time )

FileUtils.touch( 'Gemfile.lock', :mtime => 222212311800 )

JBundler.install

ensure_no_update( lock_time, classpath_time )

FileUtils.touch( 'Jarfile', :mtime => 222212311800 )

JBundler.install

ensure_no_update( lock_time, classpath_time )

FileUtils.touch( 'Jarfile.lock', :mtime => 222212311800 )

# use the updated timestamp
lock_time = File.mtime( 'Jarfile.lock' )

JBundler.install

ensure_no_update( lock_time, classpath_time )

# vim: syntax=Ruby
