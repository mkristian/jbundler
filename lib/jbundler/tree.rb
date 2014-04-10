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
      m.options[ '-f' ] = File.join( File.dirname( __FILE__ ), 
                                     'dependency_pom.rb' )
      m.options[ '-q' ] = nil unless debug
      m.verbose = debug

      @config.configure( m )

      puts '...'

      tree = File.join( File.expand_path( @config.work_dir ), 
                                 'tree.txt' )
      m.property( 'jbundler.outputFile', tree )

      m.exec( 'dependency:tree' )

      puts File.read( tree )
    end
  end
end
