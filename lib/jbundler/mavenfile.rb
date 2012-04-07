require 'jbundler/maven_util'
module JBundler

  class Mavenfile
    include MavenUtil

    def initialize(file = 'Mvnfile')
      @file = file
      @lockfile = file + ".lock"
    end

    def mtime
      File.mtime(@file)
    end

    def exists?
      File.exists?(@file)
    end

    def exists_lock?
      File.exists?(@lockfile)
    end

    def load_lockfile
      _locked = []
      if exists_lock?
        in_artifacts = false
        File.read(@lockfile).each do |line|
          if in_artifacts
            if line.strip!.size > 0
              _locked << line
            else
              in_artifacts = false
            end
          else
            if line =~ /^artifacts:/
              in_artifacts = true
            end
          end
        end
      end
      _locked
    end

    def locked
      @locked ||= load_lockfile
    end

    def locked?(coordinate)
      coord = coordinate.sub(/\:[^:]+$/, '')
      locked.detect { |l| l.sub(/\:[^:]+$/, '') == coord }
    end

    def add_artifacts(resolver)
      File.read(@file).each do |line|
        coord = to_coordinate(line)
        unless locked?(coord)
          resolver.add_artifact(to_coordinate(line),
                                to_extension(line)) if line =~ /^\s*(jar|pom)\s/
        end
      end
    end

    def add_locked_artifacts(resolver)
      locked.each { |l| resolver.add_artifact(l) }
    end

    def generate_lockfile(resolver)
      File.open(@lockfile, 'w') do |f|
        f.puts "remote:"
        resolver.repositories.each do |r|
          f.puts "  #{r.url}"
        end
        f.puts
        f.puts "artifacts:"
        resolver.dependency_coordinates.each do |d|
          f.puts "  #{d}"
        end
      end
    end
  end

end
