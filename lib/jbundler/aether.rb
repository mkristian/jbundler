require 'java'
module JBundler

  class AetherConfig

    attr_accessor :verbose, :local_maven_repository

    def verbose
      # defaults to false
      @verbose ||= (ENV['JBUNDLER_VERBOSE'] && ENV['JBUNDLER_VERBOSE'] != 'false')
    end

    def local_maven_repository
      # use maven default local repo as default
      @local_maven_repository ||= (ENV['JBUNDLER_LOCAL_MAVEN_REPOSITORY'] || 
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
        # assume this happens only when working on the git clone
        raise "jbundler.jar is missing - maybe you need to build it first ?"
      end
      java_import 'jbundler.Aether'
    end

    def initialize(config)
      unless defined? Aether
        self.class.setup_classloader
      end
      @aether = Aether.new(config.local_maven_repository, config.verbose)
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

    def add_repository(url, name = "repo_#{repos.size}")
      @aether.add_repository(name, url)
    end

    def resolve
      @aether.resolve
    end

    def classpath
      @aether.classpath
    end
    
    def dependency_map
      @aether.dependency_map
    end
    
    def repositories
      @aether.repositories
    end

    def dependency_coordinates
      @aether.dependency_coordinates
    end

    def install(coordinate, file)
      @aether.install(coordinate, file)
    end
    
  end
end
