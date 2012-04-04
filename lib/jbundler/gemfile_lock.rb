require 'rubygems'
require 'jbundler/pom'

module JBundler

  class GemfileLock

    def initialize(lockfile = 'Gemfile.lock')
      @lockfile = lockfile if File.exists?(lockfile)
    end

    def mtime
      File.mtime(@lockfile) if @lockfile
    end

    def add_artifacts(resolver, mavenfile)
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
          pom = "#{ENV['HOME']}/.m2/repository/ruby/bundler/#{spec.name}/#{spec.version}/#{spec.name}-#{spec.version}.pom"
          unless jars.empty?
            unless File.exists?(pom)
              Pom.new(pom, spec.name, spec.version, jars, "pom")
            end
            coord = "ruby.bundler:#{spec.name}:#{spec.version.to_s}"
            unless mavenfile.locked?(coord)
              resolver.add_artifact(coord, "pom")
            end
          end
        end
      end
    end
  end
  
end
