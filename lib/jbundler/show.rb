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

    def show_classpath
      return if ! @config.verbose
      @classpath_file.load_classpath
      warn ''
      warn 'jruby classpath:'
      warn '----------------'
      JBUNDLER_JRUBY_CLASSPATH.each do |path|
        warn "#{path}"
      end
      warn ''
      warn 'jbundler runtime classpath:'
      warn '---------------------------'
      JBUNDLER_CLASSPATH.each do |path|
        warn "#{path}"
      end
      warn ''
      warn 'jbundler test classpath:'
      warn '------------------------'
      if JBUNDLER_TEST_CLASSPATH.empty?
        warn "\t--- empty ---"
      else
        JBUNDLER_TEST_CLASSPATH.each do |path|
          warn "#{path}"
        end
      end
      warn ''
    end
  end
end
