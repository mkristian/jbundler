require 'maven/ruby/maven'
require 'fileutils'
module JBundler
  class Executable

    class Filter
      
      def initialize(a)
        @a = a
      end
      def method_missing(m, *args, &b)
        args[ 0 ].sub!(/^.* - /, '' )
        @a.send(m,*args, &b)
      end
    end

    def initialize( bootstrap, config, compile, verbose, *groups )
      raise "file not found: #{bootstrap}" unless File.exists?( bootstrap )
      @config = Configurator.new( config )
      @config.bootstrap = bootstrap
      @config.compile = compile
      @config.verbose = verbose
      @config.groups = groups.join( ',' )
    end

    def packit
      m = Maven::Ruby::Maven.new
      m.options[ '-f' ] = File.join( File.dirname( __FILE__ ), 
                                     'executable_pom.rb' )
      @config.configure( m )
      m.verbose = @config.verbose
      m.package( '-P', @config.compile ? :compile : :no_compile )

      puts
      puts 'now you can execute your jar like this'
      puts
      puts "\tjava -jar #{File.basename( File.expand_path( '.' ) )}_exec.jar"
      puts
    end
  end
end
