require 'jbundler/configurator'
require 'maven/ruby/maven'
require 'fileutils'
module JBundler
  class Tree

    def initialize( config )
      @config = Configurator.new( config )
    end

    def show_it( debug = false )
      m = Maven::Ruby::Maven.new
      m.options[ '-f' ] = File.join( File.dirname( __FILE__ ), 'tree_pom.rb' )
      m.options[ '-q' ] = nil unless debug
      m.verbose = debug

      @config.configure( m )

      puts '...'

      m.exec( 'org.apache.maven.plugins:maven-dependency-plugin:2.8:tree' )

      puts File.read( File.join( File.expand_path( @config.work_dir ), 
                                 'tree.txt' ) )
    end
  end
end
