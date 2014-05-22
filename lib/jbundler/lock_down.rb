require 'jbundler/configurator'
require 'jbundler/classpath_file'
require 'jbundler/vendor'
require 'jbundler/gemfile_lock'
require 'jbundler/show'
require 'maven/tools/jarfile'
require 'maven/ruby/maven'
require 'fileutils'
require 'jar_installer'
module JBundler
  class LockDown

    def initialize( config )
      @config = config
      @configurator = Configurator.new( config )
    end
    
    def vendor
      @vendor ||= JBundler::Vendor.new( @config.vendor_dir )
    end

    def update( debug = false, verbose = false )
      if vendor.vendored?
        raise 'can not update vendored jars'
      end

      FileUtils.rm_f( @config.jarfile_lock )
      
      lock_down( false, debug, verbose )
    end
    
    def lock_down( needs_vendor = false, debug = false, verbose = false )
      classpath = JBundler::ClasspathFile.new( @config.classpath_file )
      needs_update = needs_update?( classpath )
      if ( ! needs_update && ! needs_vendor ) || vendor.vendored?

        puts 'Jar dependencies are up to date !'

      else

        puts '...'
       
        locked = StringIO.new

        deps = install_dependencies( debug, verbose )

        jars = collect_jars( deps, locked, debug, verbose )

        update_files( classpath, locked, jars ) if needs_update

        vendor_it( vendor, deps ) if needs_vendor

      end
    end

    private

    def needs_update?( classpath )
      jarfile = Maven::Tools::Jarfile.new( @config.jarfile )
      gemfile_lock = JBundler::GemfileLock.new( jarfile, 
                                                @config.gemfile_lock )

      classpath.needs_update?( jarfile, gemfile_lock )
    end

    def vendor_it( vendor, deps )
      puts "vendor directory: #{@config.vendor_dir}"
      vendor.vendor_dependencies( deps )
      puts
    end

    def collect_jars( deps, locked, debug, verbose )
      jars = {}
      deps.each do |d|
        case d.scope
        when :provided
          ( jars[ :jruby ] ||= [] ) << d.file
        when :test
          ( jars[ :test ] ||= [] ) << d.file
        else
          ( jars[ :runtime ] ||= [] ) << d.file
          if( ! d.gav.match( /^ruby.bundler:/ ) )
            # TODO make Jarfile.lock depend on jruby version as well on
            # include test as well, i.e. keep the scope in place
            locked.puts d.coord
          end
        end
      end
      jars
    end

    def update_files( classpath_file, locked, jars )
      if locked.string.empty?
        FileUtils.rm_f @config.jarfile_lock
      else
        File.open( @config.jarfile_lock, 'w' ) do |f|
          f.print locked.string
        end
      end
      classpath_file.generate( jars[ :runtime ],
                               jars[ :test ],
                               jars[ :jruby ],
                               @config.local_repository )
    end

    def install_dependencies( debug, verbose )
      deps_file = File.join( File.expand_path( @config.work_dir ), 
                               'dependencies.txt' )
 
      exec_maven( debug, verbose, deps_file )

      result = []
      File.read( deps_file ).each_line do |line|
        dep = JarInstaller::Dependency.new( line )
        result << dep if dep
      end
      result
    ensure
      FileUtils.rm_f( deps_file ) if deps_file
    end

    def exec_maven( debug, verbose, output )
      m = Maven::Ruby::Maven.new
      m.options[ '-f' ] = File.join( File.dirname( __FILE__ ), 
                                     'dependency_pom.rb' )
          m.property( 'verbose', debug || verbose )
          m.options[ '-q' ] = nil if !debug and !verbose
          m.options[ '-e' ] = nil if !debug and verbose
          m.options[ '-X' ] = nil if debug
      m.verbose = debug
      m.property( 'jbundler.outputFile', output )

      @configurator.configure( m )

      m.exec( 'dependency:list' )
    end
  end
end
