#
# Copyright (C) 2013 Christian Meier
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

require 'jbundler/context'

module JBundler

  def self.context
    @context ||= JBundler::Context.new
  end

  def self.setup_test
    context.classpath.require_test_classpath
    context.config
  end

  def self.update
    if( context.classpath.needs_update?( context.jarfile, 
                                         context.gemfile_lock ) and
        not context.vendor.vendored? )
      
      warn ''
      warn 'jar bundle is outdated - use jbundle install to update bundle'
      warn ''

      aether = JBundler::AetherRuby.new( context.config )
      
      context.jarfile.populate_unlocked( aether )
      context.gemfile_lock.populate_dependencies( aether )
      context.jarfile.populate_locked( aether )
      
      aether.resolve
      
      context.classpath.generate( aether.classpath_array, [], [], 
                                  context.config.local_repository )
      context.jarfile.generate_lockfile( aether.resolved_coordinates )
    end
  end

  def self.require_jars
    if context.vendor.vendored?
      jars = context.vendor.require_jars
      if context.config.verbose
        warn "jbundler classpath:"
        jars.each do |path|
          warn "\t#{path}"
        end
      end
    elsif context.classpath.exists? && context.jarfile.exists_lock?
      require 'java'
      context.classpath.require_classpath
      if context.config.verbose
        warn "jbundler classpath:"
        JBUNDLER_CLASSPATH.each do |path|
            warn "\t#{path}"
        end
      end
      Jars.freeze_loading
    end
  end
    
  def self.setup
    if context.config.skip
      warn "skip jbundler setup" if context.config.verbose
    else
      update
      require_jars
    end
  end
end

JBundler.setup
