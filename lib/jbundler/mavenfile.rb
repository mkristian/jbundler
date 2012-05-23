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

    def mtime_lock
      File.mtime(@lockfile)
    end

    def exists_lock?
      File.exists?(@lockfile)
    end

    def load_lockfile
      _locked = []
      if exists_lock?
        File.read(@lockfile).each_line do |line|
          line.strip!
          if line.size > 0 && !(line =~ /^\s*#/)
            _locked << line
          end
        end
      end
      _locked
    end

    def locked
      @locked ||= load_lockfile
    end

    def locked?(coordinate)
      coord = coordinate.sub(/^([^:]+:[^:]+):.+/) { $1 }
      locked.detect { |l| l.sub(/^([^:]+:[^:]+):.+/) { $1 } == coord } != nil
    end

    def populate_unlocked(aether)
      File.read(@file).each_line do |line| 
        if coord = to_coordinate(line)
          unless locked?(coord)
            aether.add_artifact(coord)
          end
        elsif line =~ /^\s*(repository|source)\s/
          # allow source :name, "http://url"
          # allow source name, "http://url"
          # allow source "http://url"
          # also allow repository instead of source
          name, url = line.sub(/.*(repository|source)\s+/, '').gsub(/^:/, '').split(/,/)
          url = name unless url
          name.strip!
          name.gsub!(/^['"]|['"]$/,'')
          url.strip!
          url.gsub!(/^['"]|['"]$/,'')
          aether.add_repository(name, url)
        end
      end
    end

    def populate_locked(aether)
      locked.each { |l| aether.add_artifact(l) }
    end

    def generate_lockfile(dependency_coordinates)
      File.open(@lockfile, 'w') do |f|
        dependency_coordinates.each do |d|
          f.puts d.to_s
        end
      end
    end
  end

end
