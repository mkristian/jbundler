#
# Copyright (C) 2013 Christian Meier
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
require 'yaml'

module JBundler

  # allow yaml config in $HOME/.jbundlerrc and $PWD/.jbundlerrc
  class Config

    attr_accessor :verbose, :local_repository, :jarfile, :gemfile, :skip, :settings, :offline, :work_dir, :vendor_dir

    def initialize
      file = '.jbundlerrc'
      homefile = File.join(ENV['HOME'], file)
      home_config = YAML.load_file(homefile) if File.exists?(homefile)
      pwd_config = YAML.load_file(file) if File.exists?(file)
      File.expand_path( file )
      @config = (home_config || {}).merge(pwd_config || {})
    end

    if defined? JRUBY_VERSION
      def jbundler_env(key)
        java.lang.System.getProperty(key.downcase.gsub(/_/, '.')) ||
          ENV[key.upcase.gsub(/[.]/, '_')] ||
          @config[key.downcase.sub(/^j?bundle_/, '').sub(/[.]/, '_')]
      end
    else
      def jbundler_env(key)
        ENV[key.upcase.gsub(/[.]/, '_')] ||
          @config[key.downcase.sub(/^j?bundler/, '').sub(/[.]/, '_')]
      end
    end
    private :jbundler_env

    def skip
      skip = jbundler_env('JBUNDLE_SKIP')
      # defaults to false
      @skip ||= skip && skip != 'false'
    end

    def verbose
      verbose = jbundler_env('JBUNDLE_VERBOSE')
      # defaults to false
      @verbose ||= verbose && verbose != 'false'
    end

    def jarfile
      if File.exists?('Mvnfile')
        warn "'Mvnfile' name is deprecated, please use 'Jarfile' instead"
        @jarfile = 'Mvnfile'
      end
      @jarfile ||= jbundler_env('JBUNDLE_JARFILE') || 'Jarfile'
    end

    def jarfile_lock
      "#{jarfile}.lock"
    end

    def gemfile
      @gemfile ||= jbundler_env('BUNDLE_GEMFILE') || 'Gemfile'
    end

    def gemfile_lock
      "#{gemfile}.lock"
    end

    def classpath_file
      jbundler_env('JBUNDLE_CLASSPATH_FILE') || '.jbundler/classpath.rb'
    end

    def local_repository
      # use maven default local repo as default
      @local_maven_repository ||= jbundler_env('JBUNDLE_LOCAL_REPOSITORY')
    end

    def settings
      @settings ||= jbundler_env('JBUNDLE_SETTINGS')
    end

    def offline
      @offline ||= jbundler_env('JBUNDLE_OFFLINE')
      @offline == 'true' || @offline == true
    end

    def proxy
      @proxy ||= jbundler_env('JBUNDLE_PROXY')
      if @proxy
        warn 'proxy config is deprecated, use settings.xml instead'
      end
      @proxy
    end

    def mirror
      @mirror ||= jbundler_env('JBUNDLE_MIRROR')
      # nice to have no leading slash
      @mirror = @mirror.sub( /\/$/, '' ) if @mirror
      if @mirror
        warn 'mirror config is deprecated, use settings.xml instead'
      end
      @mirror
    end

    def rubygems_mirror
      @rubygems_mirror ||= jbundler_env('BUNDLE_RUBYGEMS_MIRROR')
      # here a leading slash is needed !!
      @rubygems_mirror =  @rubygems_mirror.sub( /([^\/])$/ , "\\1/" ) if @rubygems_mirror
      warn 'reubygems mirror config is deprecated, use bundler >=1.5 and its mirror config'
      @rubygems_mirror
    end

    def work_dir
      @work_dir ||= jbundler_env('JBUNDLE_WORK_DIR') || 'pkg'
    end

    def vendor_dir
      @vendor_dir ||= jbundler_env('JBUNDLE_VENDOR_DIR') || File.join( 'vendor', 'jars' )
    end

  end
end
