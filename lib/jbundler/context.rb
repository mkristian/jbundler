require 'maven/tools/jarfile'
require 'jbundler/classpath_file'
require 'jbundler/vendor'
require 'jbundler/gemfile_lock'
require 'jbundler/aether'

module JBundler

  class Context
    
    attr_reader :config

    def initialize
      @config = JBundler::Config.new
    end
    
    def jarfile
      @jarfile ||= Maven::Tools::Jarfile.new( @config.jarfile )
    end

    def vendor
      @vendor ||= JBundler::Vendor.new( @config.vendor_dir )
    end

    def classpath
      @classpath ||= JBundler::ClasspathFile.new( @config.classpath_file )
    end
    
    def gemfile_lock
      @gemfile_lock ||= JBundler::GemfileLock.new( jarfile, 
                                                   @config.gemfile_lock )
    end
  end
end
