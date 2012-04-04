module JBundler

  class ClasspathFile

    def initialize(classpathfile = '.jbundler/classpath.rb')
      @classpathfile = classpathfile
    end

    def require
      Kernel.require @classpathfile
    end

    def mtime
      File.mtime(@classpathfile)
    end

    def exists?
      File.exists?(@classpathfile)
    end

    def uptodate?(mavenfile, gemfile_lock)
      !mavenfile.exists? || !exists? || (mavenfile.mtime > mtime) || !mavenfile.exists_lock? || (gemfile_lock.mtime > mtime)
    end

    def generate(resolver)
      FileUtils.mkdir_p(File.dirname(@classpathfile))
      File.open(@classpathfile, 'w') do |f|
        f.puts "JBUNDLER_CLASSPATH = []"
        path_separator = java.lang.System.getProperty("path.separator").to_s
        resolver.classpath.split(/#{path_separator}/).each do |path|
          f.puts "JBUNDLER_CLASSPATH << '#{path}'" unless path =~ /pom$/
        end
        f.puts "JBUNDLER_CLASSPATH.freeze"
        f.puts "JBUNDLER_CLASSPATH.each { |c| require c }"
        f.close
      end
    end
    
  end
end
