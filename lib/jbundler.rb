require 'jbundler/mavenfile'
require 'jbundler/classpath_file'
require 'jbundler/gemfile_lock'

mavenfile = JBundler::Mavenfile.new('Mvnfile')
classpath_file = JBundler::ClasspathFile.new('.jbundler/classpath.rb')
gemfile_lock = JBundler::GemfileLock.new('Gemfile.lock')

if classpath_file.uptodate?(mavenfile, gemfile_lock)
  require 'jbundler/aether'

  aether = JBundler::AetherRuby.new(JBundler::AetherConfig.new)

  mavenfile.add_artifacts(aether)
  gemfile_lock.add_artifacts(aether, mavenfile)
  mavenfile.add_locked_artifacts(aether)

  aether.resolve

  classpath_file.generate(aether)
  mavenfile.generate_lockfile(aether)
end

if classpath_file.exists?
  require 'java'
  classpath_file.require
end
