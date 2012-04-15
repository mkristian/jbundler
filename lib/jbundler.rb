require 'jbundler/mavenfile'
require 'jbundler/classpath_file'
require 'jbundler/gemfile_lock'
require 'jbundler/aether'

config = JBundler::AetherConfig.new

mavenfile = JBundler::Mavenfile.new(config.mavenfile)
classpath_file = JBundler::ClasspathFile.new('.jbundler/classpath.rb')
gemfile_lock = JBundler::GemfileLock.new(mavenfile, config.gemfile + '.lock')

if classpath_file.needs_update?(mavenfile, gemfile_lock)
  aether = JBundler::AetherRuby.new(config)

  mavenfile.populate_unlocked(aether)
  gemfile_lock.populate_depedencies(aether)
  mavenfile.populate_locked(aether)

  aether.resolve

  classpath_file.generate(aether.classpath)
  mavenfile.generate_lockfile(aether.resolved_coordinates)
end

if classpath_file.exists?
  require 'java'
  classpath_file.require_classpath
  if config.verbose
    warn "jbundler classpath:"
    JBUNDLER_CLASSPATH.each do |path|
      warn "\t#{path}"
    end
  end
end
