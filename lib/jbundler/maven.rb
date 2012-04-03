require 'uri'
require 'tempfile'
require 'fileutils'
require 'set'
require 'jbundler/gemfile_lock'
require 'jbundler/pom'
require 'java'

# A modified maven_gemify2 taken from https://github.com/ANithian/bundler/blob/a29d4550dfb2f24372bf6e60f00e633ff92d5d64/lib/bundler/maven_gemify2.rb
module JBundler

  class Maven3NotFound < StandardError; end

  class Maven
    attr_reader :repositories

    #repositories should be an array of urls
    def initialize(*repositories)
      maven                   # ensure maven initialized
      @repositories = Set.new
      if repositories.length > 0
        @repositories.merge([repositories].flatten)
      end
      
    end

    def add_repository(repository_url)
      @repositories << repository_url
    end
    
    @@verbose = false
    def self.verbose?
      @@verbose || $DEBUG
    end
    def verbose?
      self.class.verbose?
    end
    def self.verbose=(v)
      @@verbose = v
    end

    private
    def self.maven_config
      @maven_config ||= Gem.configuration["maven"] || {}
    end
    def maven_config; self.class.maven_config; end

    def self.java_imports
      %w(
           org.codehaus.plexus.classworlds.ClassWorld
           org.codehaus.plexus.DefaultContainerConfiguration
           org.codehaus.plexus.DefaultPlexusContainer
           org.apache.maven.Maven
           org.apache.maven.repository.RepositorySystem
           org.apache.maven.execution.DefaultMavenExecutionRequest
           org.apache.maven.artifact.repository.MavenArtifactRepository
           org.apache.maven.artifact.repository.layout.DefaultRepositoryLayout
           org.apache.maven.artifact.repository.ArtifactRepositoryPolicy
           javax.xml.stream.XMLStreamWriter
           javax.xml.stream.XMLOutputFactory
           javax.xml.stream.XMLStreamException
          ).each {|i| java_import i }
    end

      def self.create_maven
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

      warn "Using Maven install at #{bin}" if verbose?

      boot = File.join(bin, "..", "boot")
      lib = File.join(bin, "..", "lib")
      ext = File.join(bin, "..", "ext")
      (Dir.glob(lib + "/*jar")  + Dir.glob(boot + "/*jar")).each {|path| require path }

      java.lang.System.setProperty("classworlds.conf", File.join(bin, "m2.conf"))
      java.lang.System.setProperty("maven.home", File.join(bin, ".."))
      java_imports

      class_world = ClassWorld.new("plexus.core", java.lang.Thread.currentThread().getContextClassLoader());
      config = DefaultContainerConfiguration.new
      config.set_class_world class_world
      config.set_name "ruby-tools"
      container = DefaultPlexusContainer.new(config);
      @@execution_request_populator = container.lookup(org.apache.maven.execution.MavenExecutionRequestPopulator.java_class)

      @@settings_builder = container.lookup(org.apache.maven.settings.building.SettingsBuilder.java_class )
      container.lookup(Maven.java_class)
    end

    def self.maven
      @maven ||= create_maven
    end
    def maven; self.class.maven; end

    def self.temp_dir
      @temp_dir ||=
        begin
          d=Dir.mktmpdir
          at_exit {FileUtils.rm_rf(d.dup)}
          d
        end
    end
    
    def temp_dir
      self.class.temp_dir
    end

    def execute(goals, pomFile, props = {})
      request = DefaultMavenExecutionRequest.new
      request.set_show_errors(true)

      props.each do |k,v|
        request.user_properties.put(k.to_s, v.to_s)
      end
      request.set_goals(goals)
      request.set_logging_level 0
      request.setPom(java.io.File.new(pomFile))
      if verbose?
        active_profiles = request.getActiveProfiles.collect{ |p| p.to_s }
        puts "active profiles:\n\t[#{active_profiles.join(', ')}]"
        puts "maven goals:"
        request.goals.each { |g| puts "\t#{g}" }
        puts "system properties:"
        request.getUserProperties.map.each { |k,v| puts "\t#{k} => #{v}" }
        puts
      end
      out = java.lang.System.out
      string_io = java.io.ByteArrayOutputStream.new
      java.lang.System.setOut(java.io.PrintStream.new(string_io))
      result = maven.execute request
      java.lang.System.out = out
      has_exceptions = false
      result.exceptions.each do |e|
        has_exceptions = true
        e.print_stack_trace
        string_io.write(e.get_message.to_java_string.get_bytes)
      end
      raise string_io.to_s if has_exceptions
      string_io.to_s
    end
    
    public
    
    def generate_classpath(mavenfile = 'Mvnfile', classpathfile = '.jbundler/classpath.rb')

      #to resolve deps and generate a classpath
      pomfile=File.join(temp_dir,
                        "pom.xml")
      Pom.new(pomfile, "mavengemify", "1.0-SNAPSHOT",
              File.read(mavenfile).split(/\n/) + GemfileLock.new.jar_deps)

      execute(["dependency:resolve","dependency:build-classpath"],pomfile,{"mdep.outputFile" => "cp.txt","mdep.fileSeparator"=>"/"})
      
      FileUtils.mkdir_p(File.dirname(classpathfile))
      File.open(classpathfile, 'w') do |f|
        f.puts "JBUNDLER_CLASSPATH = []"
        path_separator = java.lang.System.getProperty("path.separator").to_s
        File.read(File.join(temp_dir,"cp.txt")).each do |line|
          line.split(/#{path_separator}/).each do |path|
            f.puts "JBUNDLER_CLASSPATH << '#{path}'" unless path =~ /pom$/
          end
        end
        f.puts "JBUNDLER_CLASSPATH.freeze"
        f.puts "JBUNDLER_CLASSPATH.each { |c| require c }"
        f.close
      end
    end
    
  end
end
