mavenfile = 'Mvnfile'
classpathfile = '.jbundler/classpath.rb'
#TODO make the JBundler::Mavenfile lazy loading the locked version and let it
# inherit from File or so
# and put the check into ClasspathFile
if !File.exists?(classpathfile) || (File.mtime(mavenfile) > File.mtime(classpathfile)) || !File.exists?(mavenfile + ".lock") || File.mtime("Gemfile.lock") > File.mtime(classpathfile))
  require 'jbundler/aether'
  require 'jbundler/mavenfile'
  require 'jbundler/classpath_file'
  require 'jbundler/gemfile_lock'
  resolver = JBundler::Aether.new
  mfile = JBundler::Mavenfile.new(mavenfile)
  mfile.add_artifacts(resolver)
  JBundler::GemfileLock.new.add_artifacts(resolver, mfile)
  mfile.add_locked_artifacts(resolver)
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
