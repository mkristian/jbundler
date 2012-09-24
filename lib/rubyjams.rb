require 'rubygems'
require 'jbundler/aether'
require 'maven/tools/coordinate'

class Rubyjams

  include Maven::Tools::Coordinate

  def loaded
    @loaded ||= {}
  end

  def loaded_coordinates
    @loaded_coordinates ||= {}
  end

  def add_coordinates( coords )
    coords.each do |coord|
      c = coord.sub( /:[^:]+$/, '')
      v = coord.sub( /^.*:/, '')
      if loaded_coordinates.keys.member?( c )
        
        if loaded_coordinates[ c ] != v
          raise "conflict:\n\t#{c} already loaded with version #{loaded_coordinates[ c ]}\n\tthe request to load version #{v} can not be processed."
        end
      else
        loaded_coordinates[ c ] = v
      end
    end
  end

  def maybe_load_jars( specs )
    load_jars( (specs.keys - loaded.keys).collect { |k| specs[ k ] } )
    loaded.replace( specs )
  end

  def load_jars( specs )
    specs.each do |spec|
      spec.requirements.each do |req|
        req.split(/\n/).each do |r|
          coord = to_coordinate( r )
          if coord    
            aether.add_artifact( "#{coord}" )  rescue nil
          end
        end
      end
      aether.resolve
      add_coordinates( aether.resolved_coordinates )
      aether.classpath_array.each do |path|
        if require_without_jars path
          warn "using #{path}" if jb_config.verbose
          jb_classpath << path
        end
      end
    end
  end

  private
    
  def jb_classpath
    @jb_cp ||= defined?(JBUNDLER_CLASSPATH) ? JBUNDLER_CLASSPATH.dup : []
  end
  
  def jb_config
    @_jb_c ||= JBundler::Config.new
  end
  
  def aether
    @_aether ||= JBundler::AetherRuby.new(jb_config, true)
  end
end
module Kernel
  
  unless respond_to? :require_without_jars
    def jars
      @jars ||= Rubyjams.new
    end

#    alias :gem_without_jars :gem

#    def gem( *args )
#      puts args
#      gem_without_jars( *args )
#    end

    alias :require_without_jars :require

    def require( filename )
      maybe_load_jars
      require_without_jars( filename )
    end

    def maybe_load_jars
      @@gems_size ||= 0
      Gem.loaded_specs if @@gems_size == 0
      if @@gems_size < Gem.loaded_specs.size
        @@gems_size = Gem.loaded_specs.size
        jars.maybe_load_jars( Gem.loaded_specs )
      end
      true
    end
  end
end
