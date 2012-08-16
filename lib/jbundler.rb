require 'maven/tools/jarfile'
require 'jbundler/classpath_file'
require 'jbundler/gemfile_lock'
require 'jbundler/aether'

config = JBundler::Config.new

jarfile = Maven::Tools::Jarfile.new(config.jarfile)
if config.skip
  warn "skip jbundler setup"
else
  classpath_file = JBundler::ClasspathFile.new(config.classpath_file)
  gemfile_lock = JBundler::GemfileLock.new(jarfile, config.gemfile_lock)

  if classpath_file.needs_update?(jarfile, gemfile_lock)
    aether = JBundler::AetherRuby.new(config)

    jarfile.populate_unlocked(aether)
    gemfile_lock.populate_dependencies(aether)
    jarfile.populate_locked(aether)

    aether.resolve

    classpath_file.generate(aether.classpath_array)
    jarfile.generate_lockfile(aether.resolved_coordinates)
  end

  if classpath_file.exists? && jarfile.exists?
    require 'java'
    classpath_file.require_classpath
    if config.verbose
      warn "jbundler classpath:"
      JBUNDLER_CLASSPATH.each do |path|
        warn "\t#{path}"
      end
    end
  end

end
