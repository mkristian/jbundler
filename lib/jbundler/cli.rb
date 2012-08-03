require 'thor'
module JBundler
  class Cli < Thor
    no_tasks do
      def mvn
        @mvn ||= Maven::RubyMaven.new
      end
    end
    
    desc 'install', "first `bundle install` is called and then the jar dependencies will be installed. for more details see `bundle help install`, jbundler will ignore all options. the install command is also the default when no command is given."
    def install
      require 'jbundler'
      puts 'Your jbundle is complete! Use `jbundle show` to see where the bundled jars are installed.'
    end

    desc 'update', "first `bundle update` is called and if there are no options then the jar dependencies will be updated. for more details see `bundle help update`."
    def update
      if ARGV.size == 1
        require 'java'
        require 'jbundler/aether'
        config = JBundler::AetherConfig.new
        FileUtils.rm_f(config.jarfile + '.lock')
        
        require 'jbundler'
        puts 'Your jbundle is updated! Use `jbundle show` to see where the bundled jars are installed.'
      end
    end

    desc 'show', "first `bundle show` is called and if there are no options then the jar dependencies will be displayed. for more details see `bundle help show`."
    def show
      if ARGV.size == 1
        require 'java' 
        require 'jbundler/aether'
        require 'jbundler/classpath_file'
        config = JBundler::AetherConfig.new
        classpath_file = JBundler::ClasspathFile.new('.jbundler/classpath.rb')#config.classpath_file)
        if classpath_file.exists?
          classpath_file.require_classpath
          puts "JBundler classpath:"
          JBUNDLER_CLASSPATH.each do |path|
            puts "  * #{path}"
          end
        else
          puts "JBundler classpath is not installed."
        end
      end
    end
  end
end
