require 'yaml'

module JBundler

  # allow yaml config in $HOME/.jbundlerrc and $PWD/.jbundlerrc
  class Config

    attr_accessor :verbose, :local_repository, :jarfile, :gemfile, :skip, :settings, :offline

    def initialize
      file = '.jbundlerrc'
      homefile = File.join(ENV['HOME'], file)
      home_config = YAML.load_file(homefile) if File.exists?(homefile)
      pwd_config = YAML.load_file(file) if File.exists?(file)
      @config = (home_config || {}).merge(pwd_config || {})
    end

    if defined? JRUBY_VERSION
      def jbundler_env(key)
        ENV[key.upcase.gsub(/[.]/, '_')] || java.lang.System.getProperty(key.downcase.gsub(/_/, '.')) || @config[key.downcase.sub(/^j?bundler/, '').sub(/[.]/, '_')]
      end
    else
      def jbundler_env(key)
        ENV[key.upcase.gsub(/[.]/, '_')] || @config[key.downcase.sub(/^j?bundler/, '').sub(/[.]/, '_')]
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
      '.jbundler/classpath.rb'
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
    end

    def mirror
      @mirror ||= jbundler_env('JBUNDLE_MIRROR')
      # nce to have no leading slash
      @mirror.sub!( /\/$/, '' ) if @mirror
      @mirror
    end

    def rubygems_mirror
      @rubygems_mirror ||= jbundler_env('BUNDLE_RUBYGEMS_MIRROR')
      # here a leading slash is needed !!
      @rubygems_mirror.sub!( /([^\/])$/ , "\\1/" ) if @rubygems_mirror
      @rubygems_mirror
    end
  end
end
