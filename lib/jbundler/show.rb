require 'jbundler/configurator'
require 'jbundler/classpath_file'
require 'jbundler/vendor'
require 'jbundler/gemfile_lock'
require 'maven/tools/jarfile'
require 'maven/ruby/maven'
require 'fileutils'
module JBundler
  class Show

    def initialize( config )
      @config = config
      @classpath_file = JBundler::ClasspathFile.new( @config.classpath_file )
    end

    def do_it( debug = false )
      jarfile = Maven::Tools::Jarfile.new( @config.jarfile )
      vendor = JBundler::Vendor.new( @config.vendor_dir )
      gemfile_lock = JBundler::GemfileLock.new( jarfile, 
                                                @config.gemfile_lock )
    end

    def show_classpath
      @classpath_file.require_classpath
      warn "jruby core classpath:"
      JBUNDLER_JRUBY_CLASSPATH.each do |path|
        warn "\t#{path}"
      end
      warn "jbundler runtime classpath:"
      JBUNDLER_CLASSPATH.each do |path|
        warn "\t#{path}"
      end
      warn "jbundler test classpath:"
      if JBUNDLER_TEST_CLASSPATH.empty?
        warn "\t--- empty ---"
      else
        JBUNDLER_TEST_CLASSPATH.each do |path|
          warn "\t#{path}"
        end
      end
    end
  end
end
