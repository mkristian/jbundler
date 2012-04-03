require 'jbundler/maven'
mavenfile = 'Mvnfile'
classpathfile = '.jbundler/classpath.rb'
if !File.exists?(classpathfile) || (File.mtime(mavenfile) > File.mtime(classpathfile))
  JBundler::Maven.new.generate_classpath(mavenfile,classpathfile)
end
if File.exists?(classpathfile)
  require 'java'
  require classpathfile 
  true
else
  false
end
