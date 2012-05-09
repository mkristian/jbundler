require 'java'
require 'yaml'

module JBundler

  # allow yaml config in $HOME/.jbundlerrc and $PWD/.jbundlerrc
  class AetherConfig

    attr_accessor :verbose, :local_repository, :jarfile, :gemfile

    def initialize
      file = '.jbundlerrc'
      homefile = File.join(ENV['HOME'], file)
      home = YAML.load_file() if File.exists? homefile
      pwd = YAML.load_file(file) if File.exists? file
      @config = (home || {}).merge(pwd || {})
    end

    def verbose
      verbose = ENV['JBUNDLE_VERBOSE'] || @config['verbose']
      # defaults to false
      @verbose ||= verbose && verbose != 'false'
    end

    def jarfile
      if File.exists?('Mvnfile')
        warn "'Mvnfile' name is deprecated, please use 'Jarfile' instead"
        @jarfile = 'Mvnfile'
      end
      @jarfile ||= ENV['JBUNDLE_JARFILE'] || @config['jarfile'] || 'Jarfile'
    end

    def gemfile
      @gemfile ||= ENV['BUNDLE_GEMFILE'] || 'Gemfile'
    end

    def local_repository
      # use maven default local repo as default
      @local_maven_repository ||= (ENV['JBUNDLE_LOCAL_REPOSITORY'] || 
                                   @config['local_repository']|| 
                                   File.join( ENV['HOME'], ".m2", "repository"))
    end
  end

  class AetherRuby

    def self.setup_classloader
      maven_home = File.dirname(File.dirname(Gem.bin_path('ruby-maven', 
                                                           'rmvn')))
      # TODO reduce to the libs which are really needed
      Dir.glob(File.join(maven_home, 'lib', "*jar")).each {|path| require path }
      begin
        require 'jbundler.jar'
      rescue LoadError
        # allow the classes already be added to the classloader
        begin
          java_import 'jbundler.Aether'
        rescue NameError
          # assume this happens only when working on the git clone
          raise "jbundler.jar is missing - maybe you need to build it first ?"
        end
      end
      java_import 'jbundler.Aether'
    end

    def initialize(config = AetherConfig.new)
      unless defined? Aether
        self.class.setup_classloader
      end
      @aether = Aether.new(config.local_repository, config.verbose)
    end

    def add_artifact(coordinate, extension = nil)
      if extension
        coord = coordinate.split(/:/)
        coord.insert(2, extension)
        @aether.add_artifact(coord.join(":"))
      else
        @aether.add_artifact(coordinate)
      end
    end

    def add_repository(name, url)
      @aether.add_repository(name, url)
    end

    def resolve
      @aether.resolve
    end

    def classpath
      @aether.classpath
    end
   
    def repositories
      @aether.repositories
    end

    def artifacts
      @aether.artifacts
    end

    def resolved_coordinates
      @aether.resolved_coordinates
    end

    def install(coordinate, file)
      @aether.install(coordinate, file)
    end
    
  end
end
