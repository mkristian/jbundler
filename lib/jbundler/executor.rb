require 'maven/ruby/maven'
require 'maven/tools/artifact'
require 'maven/tools/gemspec_dependencies'
require 'fileutils'
require 'jar_dependencies'
module JBundler
  
  class Executor

    attr_reader :debug, :verbose

    def initialize( debug = false, verbose = false )
      @debug = debug
      @verbose = verbose
    end

    def maven_new
      m = Maven::Ruby::Maven.new
      m.property( 'jbundler.basedir', File.expand_path( basedir ) )
      m.property( 'jbundler.jarfile', JBundler.jarfile )
      m.property( 'verbose', (debug || verbose) == true )
      if debug
        m.options[ '-X' ] = nil
      elsif verbose
        m.options[ '-e' ] = nil
      else
        m.options[ '-q' ] = nil
      end
      m.verbose = debug
      m
    end
    private :maven_new

    def basedir
      File.expand_path( '.' )
    end

    def exec( maven, *args )
      attach_jar_coordinates( maven )
      maven.options[ '-f' ] = File.expand_path( '../pom.rb', __FILE__ )
      maven.exec( *args )
    end

    def attach_jar_coordinates( maven )
      load_path = $LOAD_PATH.dup
      require 'bundler/setup'
      done = []
      index = 0
      Gem.loaded_specs.each do |name, spec|
        # TODO get rid of this somehow
        deps = Maven::Tools::GemspecDependencies.new( spec )
        deps.java_dependency_artifacts.each do |a|
          unless done.include? a.key
            maven.property( "jbundler.jars.#{index}", a.to_s )
            index += 1
            done << a.key
          end
        end
      end
    ensure
      $LOAD_PATH.replace( load_path )
    end

    def lock_down( options = {} )
      out = File.expand_path( '.jbundler.output' )
      tree = File.expand_path( '.jbundler.tree' )
      maven = maven_new
      maven.property( 'maven.repo.local', Jars.home )
      maven.property( 'jars.outputFile', out )
      maven.property( 'jars.home', options[ :vendor_dir ] || Jars.home )
      maven.property( 'jars.lock', File.expand_path( 'Jars.lock' ) )
      maven.property( 'jars.force', options[ :force ] )
      maven.property( 'jars.update', options[ :update ] ) if options[ :update ]
      args = [ 'gem:jars-lock' ]

      if options[ :tree ]
        args += [ 'dependency:tree', '-P -gemfile.lock', '-DoutputFile=' + file ]
      end
      puts
      puts '-- jar root dependencies --'
      puts
      status = exec( maven, *args )
      exit 1 unless status
      if File.exists?( tree )
        puts
        puts '-- jar dependency tree --'
        puts
        puts File.read( tree )
        puts
      end
      puts
      puts File.read( out ).gsub( /#{File.dirname(out)}\//, '' )
      puts
    ensure
      FileUtils.rm_f out
      FileUtils.rm_f tree
    end
  end
end
