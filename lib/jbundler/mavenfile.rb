require 'jbundler/maven_util'
module JBundler

  class Mavenfile
    include MavenUtil

    def initialize(file = 'Mvnfile')
      @file = file
    end

    def add_artifacts(resolver)
      File.read(@file).each do |line|
        resolver.add_artifact(to_coordinate(line),
                              to_extension(line)) if line =~ /^\s*(jar|pom)\s/
      end
    end

    def generate_lockfile(resolver)
      File.open(@file + ".lock", 'w') do |f|
        f.puts "remote:"
        resolver.repositories.each do |r|
          f.puts "  #{r.url}"
        end
        f.puts
        f.puts "jars:"
        resolver.dependency_map.each do |k,v|
          f.puts "  #{k}"
          v.each do |d|
            f.puts "    #{d}"
          end
        end
      end
    end
  end

end
