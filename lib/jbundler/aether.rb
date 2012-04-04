require 'java'
module JBundler

  class Maven

    def self.home
      
      bin = nil
      if ENV['M2_HOME'] # use M2_HOME if set
        bin = File.join(ENV['M2_HOME'], "bin")
      else
        ENV['PATH'].split(File::PATH_SEPARATOR).detect do |path|
          mvn = File.join(path, "mvn")
          if File.exists?(mvn)
            if File.symlink?(mvn)
              link = File.readlink(mvn)
              if link =~ /^\// # is absolute path
                bin = File.dirname(File.expand_path(link))
              else # is relative path so join with dir of the maven command
                bin = File.dirname(File.expand_path(File.join(File.dirname(mvn), link)))
              end
            else # is no link so just expand it
              bin = File.expand_path(path)
            end
          else
            nil
          end
        end
      end
      bin = "/usr/share/maven2/bin" if bin.nil? # OK let's try debian default
      if File.exists?(bin)
        @mvn = File.join(bin, "mvn")
        if Dir.glob(File.join(bin, "..", "lib", "maven-core-3.*jar")).size == 0
          begin
            gem 'ruby-maven', ">=0"
            bin = File.dirname(Gem.bin_path('ruby-maven', "rmvn"))
            @mvn = File.join(bin, "rmvn")
          rescue LoadError
            bin = nil
          end
        end
      else
        bin = nil
      end
      raise Maven3NotFound.new("can not find maven3 installation. install ruby-maven with\n\n\tjruby -S gem install ruby-maven\n\n") if bin.nil?

      File.dirname(bin)
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
      require File.join(File.dirname(__FILE__), '..', 'jbundler.jar') 
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
