require 'maven/tools/jarfile'
require 'maven/tools/dsl'
require 'maven/ruby/maven'
require 'fileutils'
module JBundler
  class Executable

    BOOTSTRAP = 'jar-bootstrap.rb'

    include Maven::Tools::DSL

    def initialize( bootstrap, config )
      raise "file not found: #{bootstrap}" unless File.exists?( bootstrap )
      @bootstrap = bootstrap
      @config = config
    end

    attr_accessor :clean, :groups

    def groups
      @groups || []
    end

    def setup_jruby( jruby )
      if ( jruby < '1.7' )
        warn 'jruby version below 1.7 uses jruby-complete'
        jar 'org.jruby:jruby-core', jruby
      elsif ( jruby < '1.7.5' )
        jar 'org.jruby:jruby-core', jruby
      else
        jar 'org.jruby:jruby', jruby
      end
    end
    private :setup_jruby

    def jruby_home( path )
      File.join( 'META-INF/jruby.home/lib/ruby/gems/shared', path )
    end

    def packit
      require 'bundler'
      Bundler.setup( *groups )

      require 'jbundler'
      jarfile = ::Maven::Tools::Jarfile.new( @config.jarfile )

      work_dir = File.join( @config.work_dir, 'executable' )
      FileUtils.rm_rf( work_dir )
      FileUtils.mkdir_p( work_dir )
      FileUtils.cp( @bootstrap, File.join( work_dir,
                                           BOOTSTRAP ) )
      project = maven do
        jarfile.locked.each do |dep|
          artifact( dep )
        end
        build.final_name = model.artifact_id
        build.directory = work_dir
        resource do 
          directory work_dir
          includes [ BOOTSTRAP ]
        end
        Gem.loaded_specs.values.each do |s|
          resource do 
            directory s.full_gem_path
            target_path File.join( jruby_home( 'gems' ),
                                   File.basename( s.full_gem_path ) )
            if s.full_gem_path == File.expand_path( '.' )
              excludes [ "**/#{File.basename( @config.work_dir )}/**" ]
            end
          end
          resource do 
            directory File.dirname( s.loaded_from )
            includes [ File.basename( s.loaded_from ) ]
            target_path jruby_home( 'specifications' )
          end            
        end
        
        properties( 'maven.test.skip' => true,
                    'project.build.sourceEncoding' => 'utf-8' )

        jarfile.populate_unlocked do |dsl|
          setup_jruby( dsl.jruby || '1.7.4' )
          local = dsl.artifacts.select do |a|
            a[ :system_path ]
          end
          if local
            localrepo = File.join( work_dir, 'localrepo' )
            repository( "file:#{localrepo}", :id => 'localrepo' )
            local.each do |a|
              file = "#{localrepo}/#{a[ :group_id ].gsub( /\./, File::SEPARATOR)}/#{a[ :artifact_id ]}/#{a[ :version ]}/#{a[ :artifact_id ]}-#{a[ :version ]}.#{a[ :type ]}"
              FileUtils.mkdir_p( File.dirname( file ) )
              FileUtils.cp( a.delete( :system_path ), file )
              a.delete( :scope )
              jar a
            end
          end
        end

        plugin( :shade, '2.1',
                :transformers => [ { '@implementation' => 'org.apache.maven.plugins.shade.resource.ManifestResourceTransformer',
                                     :mainClass => 'org.jruby.JarBootstrapMain' } ] ) do
          execute_goals( 'shade', :phase => 'package' )
        end
      end

      m = Maven::Ruby::Maven.new( project, '.executable.pom.xml' )
      m.package
      
      FileUtils.rm_f( 'dependency-reduced-pom.xml' )
      puts
      puts 'now you can execute your jar like this'
      puts
      puts "\tjava -jar #{work_dir}/#{project.artifact_id}.jar"
      puts
    end
  end
end
