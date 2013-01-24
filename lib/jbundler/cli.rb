require 'thor'
module JBundler
  class Cli < Thor
    no_tasks do
      def mvn
        @mvn ||= Maven::Ruby::Maven.new
      end

      def do_show
        require 'java' 
        require 'jbundler/config'
        require 'jbundler/classpath_file'
        config = JBundler::Config.new
        classpath_file = JBundler::ClasspathFile.new(config.classpath_file)
        if classpath_file.exists?
          classpath_file.require_classpath unless defined? JBUNDLER_CLASSPATH
          puts "JBundler classpath:"
          JBUNDLER_CLASSPATH.each do |path|
            puts "  * #{path}"
          end
        else
          puts "JBundler classpath is not installed."
        end
      end
    end
    
    desc 'console', 'irb session with gems and/or jars and with lazy jar loading.'
    def console
      # dummy - never executed !!!
    end
    
    desc 'install', "first `bundle install` is called and then the jar dependencies will be installed. for more details see `bundle help install`, jbundler will ignore all options. the install command is also the default when no command is given."
    def install
      require 'jbundler'
      do_show
      puts 'Your jbundle is complete! Use `jbundle show` to see where the bundled jars are installed.'
    end

    desc 'update', "first `bundle update` is called and if there are no options then the jar dependencies will be updated. for more details see `bundle help update`."
    def update
      if ARGV.size == 1
        require 'java'
        require 'jbundler/config'
        config = JBundler::Config.new
        FileUtils.rm_f(config.jarfile_lock)
        
        require 'jbundler'
        do_show
        puts ''
        puts 'Your jbundle is updated! Use `jbundle show` to see where the bundled jars are installed.'
      end
    end

    desc 'show', "first `bundle show` is called and if there are no options then the jar dependencies will be displayed. for more details see `bundle help show`."
    def show
      if ARGV.size == 1
        do_show
     end
    end
  end
end
