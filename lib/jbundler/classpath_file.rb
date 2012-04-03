module JBundler

  class ClasspathFile

    def self.generate(resolver, classpathfile = '.jbundler/classpath.rb')
      FileUtils.mkdir_p(File.dirname(classpathfile))
      File.open(classpathfile, 'w') do |f|
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
