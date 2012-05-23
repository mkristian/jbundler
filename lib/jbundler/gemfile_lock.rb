require 'rubygems'
require 'jbundler/pom'

module JBundler

  class GemfileLock

    def initialize(mavenfile, lockfile = 'Gemfile.lock')
      @mavenfile = mavenfile
      @lockfile = lockfile if File.exists?(lockfile)
    end

    def mtime
      File.mtime(@lockfile) if @lockfile
    end

    def populate_dependencies(aether)
      if @lockfile
        # assuming we run in Bundler context here 
        # at we have a Gemfile.lock :)
        Bundler.load.specs.each do |spec|
          jars = []
          spec.requirements.each do |rr|
            rr.split(/\n/).each do |r|
              jars << r if r =~ /^jar\s/
            end
          end
          unless jars.empty?
            pom = Pom.new(spec.name, spec.version, jars, "pom")
            aether.install(pom.coordinate, pom.file)
            unless @mavenfile.locked?(pom.coordinate)
              aether.add_artifact(pom.coordinate)
            end
          end
        end
      end
    end
  end
  
end
