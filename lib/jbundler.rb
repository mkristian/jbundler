mavenfile = 'Mvnfile'
classpathfile = '.jbundler/classpath.rb'
if !File.exists?(classpathfile) || (File.mtime(mavenfile) > File.mtime(classpathfile))
  require 'jbundler/aether'
  require 'jbundler/mavenfile'
  require 'jbundler/classpath_file'
  require 'jbundler/gemfile_lock'
  resolver = JBundler::Aether.new
  mfile = JBundler::Mavenfile.new(mavenfile)
  mfile.add_artifacts(resolver)
  JBundler::GemfileLock.new.add_artifacts(resolver)
  resolver.resolve
  JBundler::ClasspathFile.generate(resolver)
  mfile.generate_lockfile(resolver)
end
if File.exists?(classpathfile)
  require 'java'
  require classpathfile 
  true
else
  false
end
