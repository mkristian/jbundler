require 'yaml'

module JBundler

  # allow yaml config in $HOME/.jbundlerrc and $PWD/.jbundlerrc
  class Config

    attr_accessor :verbose, :local_repository, :jarfile, :gemfile, :skip

    def initialize
      file = '.jbundlerrc'
      homefile = File.join(ENV['HOME'], file)
      home_config = YAML.load_file(homefile) if File.exists?(homefile)
      pwd_config = YAML.load_file(file) if File.exists?(file)
      @config = (home_config || {}).merge(pwd_config || {})
    end

    if defined? JRUBY_VERSION
      def jbundler_env(key)
        ENV[key.upcase.gsub(/./, '_')] || java.lang.System.getProperty(key.downcase.gsub(/_/, '.')) || @config[key.downcase.sub(/^j?bundler/, '').sub(/./, '_')]
      end
    else
      def jbundler_env(key)
        ENV[key.upcase.gsub(/./, '_')] || @config[key.downcase.sub(/^j?bundler/, '').sub(/./, '_')]
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
      @local_maven_repository ||= (jbundler_env('JBUNDLE_LOCAL_REPOSITORY') ||
                                   File.join( ENV['HOME'], ".m2", "repository"))
    end
  end
end
