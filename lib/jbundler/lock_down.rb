require 'jbundler/configurator'
require 'jbundler/classpath_file'
require 'jbundler/vendor'
require 'jbundler/gemfile_lock'
require 'jbundler/show'
require 'maven/tools/jarfile'
require 'maven/ruby/maven'
require 'fileutils'
module JBundler
  class LockDown

    def initialize( config )
      @config = config
      @configurator = Configurator.new( config )
    end

    def lock_down( needs_vendor = false, debug = false )
      jarfile = Maven::Tools::Jarfile.new( @config.jarfile )
      vendor = JBundler::Vendor.new( @config.vendor_dir )
      classpath_file = JBundler::ClasspathFile.new( @config.classpath_file )
      gemfile_lock = JBundler::GemfileLock.new( jarfile, 
                                                @config.gemfile_lock )

      needs_update = classpath_file.needs_update?( jarfile, gemfile_lock )
      if( ( ! needs_update ||
            vendor.vendored? ) && ! vendor )

        puts 'up to date'

      else

        puts '...'

        exec_maven( debug )

        deps_file = File.join( File.expand_path( @config.work_dir ), 
                               'dependencies.txt' )
        deps = StringIO.new
        jars = {}
        vendor_map = {}
        File.read( deps_file ).each_line do |line| 
          if line.match /:jar:/
            jar = line.sub( /.+:/, '' ).sub( /\s$/, '' )
            unless line.match /:provided/
              vendor_map[ line.sub( /:[^:]+:[^:]+$/, '' )
                            .sub( /^\s+/, '' ) ] = jar
            end
            case line
            when /:provided:/
              ( jars[ :jruby ] ||= [] ) << jar
            when /:test:/
              ( jars[ :test ] ||= [] ) << jar
            else
              ( jars[ :runtime ] ||= [] ) << jar
            end
          end
          # TODO make lock depend on jruby version as well on
          # include test as well, i.e. keep the scope in place
          if( line.match( /:compile:|:runtime:/ ) &&
              ! line.match( /^ruby.bundler:/ ) )
            deps.puts line.sub( /:[^:]+:[^:]+$/, '' ).sub( /^\s+/, '' )
          end
        end
        if needs_update
          if deps.string.empty?
            FileUtils.rm_f @config.jarfile_lock
          else
            File.open( @config.jarfile_lock, 'w' ) do |f|
              f.print deps.string
            end
          end
          classpath_file.generate( jars[ :runtime ],
                                   jars[ :test ],
                                   jars[ :jruby ],
                                   @config.local_repository )
        end
        if needs_vendor
          puts "vendor directory: #{@config.vendor_dir}"
          vendor_map.each do |key, file|
            vendor.copy_jar( key, file )
          end
          puts
        end
        if @config.verbose
          Show.new( @config ).show_classpath
          puts
        end
        puts 'jbundle complete'
      end
    end

    private
    
    def exec_maven( debug )
      m = Maven::Ruby::Maven.new
      m.options[ '-f' ] = File.join( File.dirname( __FILE__ ), 
                                     'lock_down_pom.rb' )
      m.options[ '-q' ] = nil unless debug
      m.verbose = debug
      
      @configurator.configure( m )
      
      m.exec
    end
  end
end
