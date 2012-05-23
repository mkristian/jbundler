module JBundler

  class ClasspathFile

    def initialize(classpathfile = '.jbundler/classpath.rb')
      @classpathfile = classpathfile
    end

    def require_classpath
      load File.expand_path @classpathfile
    end

    def mtime
      File.mtime(@classpathfile)
    end

    def exists?
      File.exists?(@classpathfile)
    end

    def needs_update?(jarfile, gemfile_lock)
      !exists? || !jarfile.exists_lock? || (jarfile.exists? && (jarfile.mtime > mtime)) || (jarfile.exists_lock? && (jarfile.mtime_lock > mtime)) || (gemfile_lock.mtime > mtime)
    end

    def generate(classpath)
      FileUtils.mkdir_p(File.dirname(@classpathfile))
      File.open(@classpathfile, 'w') do |f|
        f.puts "JBUNDLER_CLASSPATH = []"
        classpath.split(/#{File::PATH_SEPARATOR}/).each do |path|
          f.puts "JBUNDLER_CLASSPATH << '#{path}'" unless path =~ /pom$/
        end
        f.puts "JBUNDLER_CLASSPATH.freeze"
        f.puts "JBUNDLER_CLASSPATH.each { |c| require c }"
        f.close
      end
    end
    
  end
end
