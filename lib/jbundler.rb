require 'jbundler/mavenfile'
require 'jbundler/classpath_file'
require 'jbundler/gemfile_lock'

mavenfile = JBundler::Mavenfile.new('Mvnfile')
classpath_file = JBundler::ClasspathFile.new('.jbundler/classpath.rb')
gemfile_lock = JBundler::GemfileLock.new('Gemfile.lock')

if classpath_file.uptodate?(mavenfile, gemfile_lock)
  require 'jbundler/aether'

  resolver = JBundler::Aether.new

  mavenfile.add_artifacts(resolver)
  gemfile_lock.add_artifacts(resolver, mavenfile)
  mavenfile.add_locked_artifacts(resolver)

  resolver.resolve

  classpath_file.generate(resolver)
  mavenfile.generate_lockfile(resolver)
end

if classpath_file.exists?
  require 'java'
  classpath_file.require
end
