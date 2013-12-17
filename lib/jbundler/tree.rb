require 'jbundler/configurator'
require 'maven/tools/jarfile'
require 'maven/tools/dsl'
require 'maven/tools/model'
require 'maven/ruby/maven'
require 'fileutils'
module JBundler
  class Tree

    include Maven::Tools::DSL

    def initialize( config )
      @config = Configurator.new( config )
    end

    def show_it( debug = false )
      m = Maven::Ruby::Maven.new
      m.options[ '-f' ] = File.join( File.dirname( __FILE__ ), 'tree_pom.rb' )
      @config.configure( m )

      unless debug
        # silence the output
        old = java.lang.System.err
        java.lang.System.err = java.io.PrintStream.new( java.io.ByteArrayOutputStream.new )
      end

      m.exec( 'org.apache.maven.plugins:maven-dependency-plugin:2.8:tree' )

      puts File.read( File.join( File.expand_path( @config.work_dir ), 
                                 'tree.txt' ) )
      
    ensure
      java.lang.System.err = old if old
    end
  end
end
