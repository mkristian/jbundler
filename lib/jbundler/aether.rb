require 'java'
module JBundler

  class Maven
    def self.home
      @home ||= File.dirname(File.dirname(Gem.bin_path('ruby-maven', "rmvn")))
    end
  end

  class Aether
    def self.java_imports
      %w(
           org.sonatype.aether.util.artifact.DefaultArtifact
           org.sonatype.aether.repository.RemoteRepository
           jbundler.DependencyResolver
          ).each {|i| java_import i }
    end

    def self.setup_classloader
      # TODO reduce to the libs which are really needed
      Dir.glob(File.join(Maven.home, 'lib', "*jar")).each {|path| require path }
      require 'jbundler.jar'
      java_imports
    end


    def initialize
      self.class.setup_classloader
      @resolver = DependencyResolver.new
    end

    def add_artifact(coordinate, extension = nil)
      if extension
        coord = coordinate.split(/:/)
        coord.insert(2, extension)
        artifact = DefaultArtifact.new(*coord)
      else
        artifact = DefaultArtifact.new(coordinate)
      end
      @resolver.add_artifact(artifact)
    end

    def add_repository(url, name = "repo_#{repos.size}")
      @resolver.add_repository(RemoteRepository.new(name, "default", url))
    end

    def resolve
      @resolver.resolve
    end

    def classpath
      @resolver.classpath
    end
    
    def dependency_map
      @resolver.dependency_map
    end
    
    def repositories
      @resolver.repositories
    end

    def dependency_coordinates
      @resolver.dependency_coordinates
    end
    
  end
end
