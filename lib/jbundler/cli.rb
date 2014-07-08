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
require 'bundler/vendored_thor'
require 'jbundler/config'
require 'jbundler/executable'
require 'jbundler/tree'
require 'jbundler/lock_down'
require 'jbundler/jruby_complete'
module JBundler
  class Cli < Thor
    no_tasks do
      def config
        @config ||= JBundler::Config.new
      end

      def unvendor
        vendor = JBundler::Vendor.new( config.vendor_dir )
        vendor.clear
      end

      def vendor
        vendor = JBundler::Vendor.new( config.vendor_dir )
        if vendor.vendored?
          raise "already vendored. please 'jbundle install --no-deployment before."
        else
          vendor.setup( JBundler::ClasspathFile.new( config.classpath_file ) )
        end
      end

      def say_bundle_complete
        puts ''
        puts 'Your jbundle is complete! Use `jbundle show` to see where the bundled jars are installed.'
      end
    end

    desc 'jruby_complete', 'pack a jruby-complete jar with custom dependencies and maybe adjust jruby dependencies like newer versions of joda-time or snakeyaml', :hide => true
    method_option :clean, :type => :boolean, :default => false
    method_option :verbose, :type => :boolean, :default => false
    method_option :debug, :type => :boolean, :default => false
    method_option :show, :type => :boolean, :default => false, :desc => 'show versions of all libraries from jruby'
    def jruby_complete
      jc = JBundler::JRubyComplete.new( config, options )
      if options[ :show ]
        jc.show_versions
      else
        jc.packit
      end
    end

    desc 'tree', 'display a graphical representation of the dependency tree'
    #method_option :details, :type => :boolean, :default => false
    def tree
      JBundler::Tree.new( config ).show_it
    end

    desc 'install', "first `bundle install` is called and then the jar dependencies will be installed. for more details see `bundle help install`, jbundler will ignore most options. the install command is also the default when no command is given."
    method_option :vendor, :type => :boolean, :default => false, :desc => 'vendor jars into vendor directory (jbundler only).'
    method_option :debug, :type => :boolean, :default => false, :desc => 'enable maven debug output (jbundler only).'
    method_option :verbose, :type => :boolean, :default => false, :desc => 'enable maven output (jbundler only).'
    method_option :deployment, :type => :boolean, :default => false, :desc => "copy the jars into the vendor/jars directory (or as configured). these vendored jars have preference before the classpath jars !"
    method_option :no_deployment, :type => :boolean, :default => false, :desc => 'clears the vendored jars'
    method_option :path, :type => :string
    method_option :without, :type => :array
    method_option :system, :type => :boolean
    method_option :local, :type => :boolean
    method_option :binstubs, :type => :string
    method_option :trust_policy, :type => :string
    method_option :gemfile, :type => :string
    method_option :jobs, :type => :string
    method_option :retry, :type => :string
    method_option :no_cache, :type => :boolean
    method_option :quiet, :type => :boolean
    def install
      JBundler::LockDown.new( config ).lock_down( options[ :vendor ],
                                                  options[ :debug ] ,
                                                  options[ :verbose ] )
      config.verbose = ! options[ :quiet ]
      Show.new( config ).show_classpath
      puts 'jbundle complete' unless options[ :quiet ]
    end

    desc 'executable', 'create an executable jar with a given bootstrap.rb file\nLIMITATION: only for jruby 1.6.x and newer'
    method_option :bootstrap, :type => :string, :aliases => '-b', :required => true, :desc => 'file which will be executed when the jar gets executed'
    method_option :compile, :type => :boolean, :aliases => '-c', :default => false, :desc => 'compile the ruby files from the lib directory'
    method_option :verbose, :type => :boolean, :aliases => '-v', :default => false, :desc => 'more output'
    method_option :groups, :type => :array, :aliases => '-g', :desc => 'bundler groups to use for determine the gems to include in the jar file'
    def executable
      ex = JBundler::Executable.new( options[ 'bootstrap' ], config, options[ 'compile' ], options[ :verbose ], *( options[ 'groups' ] || [:default] ) )
      ex.packit
    end

    desc 'console', 'irb session with gems and/or jars and with lazy jar loading.'
    def console
      # dummy - never executed !!!
    end
    
    desc 'lock_down', "first `bundle install` is called and then the jar dependencies will be installed. for more details see `bundle help install`, jbundler will ignore all options. the install command is also the default when no command is given. that is kept as fall back in cases where the new install does not work as before."
    method_option :deployment, :type => :boolean, :default => false, :desc => "copy the jars into the vendor/jars directory (or as configured). these vendored jars have preference before the classpath jars !"
    method_option :no_deployment, :type => :boolean, :default => false, :desc => 'clears the vendored jars'
    method_option :path, :type => :string
    method_option :without, :type => :array
    method_option :system, :type => :boolean
    method_option :local, :type => :boolean
    method_option :binstubs, :type => :string
    method_option :trust_policy, :type => :string
    method_option :gemfile, :type => :string
    method_option :jobs, :type => :string
    method_option :retry, :type => :string
    method_option :no_cache, :type => :boolean
    method_option :quiet, :type => :boolean
    def lock_down
      require 'jbundler'

      unvendor if options[ :no_deployment ]

      vendor if options[ :deployment ]

      config.verbose = ! options[ :quiet ]

      Show.new( config ).show_classpath

      say_bundle_complete unless options[ :quiet ]
    end

    desc 'update', "first `bundle update` is called and if there are no options then the jar dependencies will be updated. for more details see `bundle help update`."
    method_option :debug, :type => :boolean, :default => false, :desc => 'enable maven debug output (jbundler only).'
    method_option :verbose, :type => :boolean, :default => false, :desc => 'enable maven output (jbundler only).'
    def update
      return unless ARGV.size == 1
        
      JBundler::LockDown.new( config ).update( options[ :debug ] ,
                                               options[ :verbose ] )

      config.verbose = ! options[ :quiet ]
      Show.new( config ).show_classpath
      puts ''
      puts 'Your jbundle is updated! Use `jbundle show` to see where the bundled jars are installed.'
    end

    desc 'show', "first `bundle show` is called and if there are no options then the jar dependencies will be displayed. for more details see `bundle help show`."
    def show
      config.verbose = true
      Show.new( config ).show_classpath
    end
  end
end
