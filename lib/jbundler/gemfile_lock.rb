require 'rubygems'
require 'jbundler/pom'

module JBundler

  class GemfileLock

    def gemspecs
      @gemspecs ||= {}
    end

    def initialize(lockfile = 'Gemfile.lock')
      if File.exists?(lockfile)
        is_path = false
        current = nil
        File.read(lockfile).each do |line|
          if line =~ /^PATH/
            is_path = true
          elsif line.strip!.empty?
            current = nil
            is_path = false
          end
          if is_path
            if line =~ /remote:/
              current = line.sub(/remote:/, '').strip
            elsif !(line =~ /\:/) && current
              file =  line.sub(/\(.*/, '').strip
              specfile = File.join(File.dirname(current), file + ".gemspec")
              if !File.exists?(specfile)
                specfile = File.join(current, file + ".gemspec")
              end
              gemspecs[file] = specfile
            end
          end
        end
      end
    end

    def add_artifacts(resolver, mavenfile)
      gemspecs.each do |name, s|
        spec = Gem::Specification.load(s)
        jars = []
        spec.requirements.each do |r|
          jars << r if r =~ /^jar\s/
        end
        pom = "#{ENV['HOME']}/.m2/repository/ruby/bundler/#{name}/#{spec.version}/#{name}-#{spec.version}.pom"
        unless jars.empty?
          unless File.exists?(pom)
            Pom.new(pom, name, spec.version, jars, "pom")
          end
          coord = "ruby.bundler:#{name}:#{spec.version.to_s}"
          unless mavenfile.locked?(coord)
            resolver.add_artifact(coord, "pom")
          end
        end
      end
    end
  end
  
end
