require 'rubygems'
require 'lock_jar'

class Jars

  def loaded
    @loaded ||= {}
  end

  def maybe_load_jars( specs )
    load_jars( (specs.keys - loaded.keys).collect { |k| specs[ k ] } )
    loaded.replace( specs )
  end

  def load_jars( specs )
    puts "DO LOAD JARS FOR #{specs.collect { |k| k }.join(',')}"
    specs.each do |spec|
      gem_dir = spec.gem_dir rescue spec.full_gem_path # fallback for --1.8 mode
      lockfile = File.join( gem_dir, "Jarfile.lock" )
      if File.exists? lockfile
        puts "#{spec.name} has Jarfile.lock, loading jars"
        LockJar.load( lockfile )
      end  
    end
  end

end
module Kernel
  
  unless respond_to? :require_without_jars
    def jars
      @jars||= Jars.new
    end
    alias :require_without_jars :require
    def require fn
      
      #puts fn.inspect
      
      if require_without_jars fn
        @@gems_size ||= 0
        Gem.loaded_specs if @@gems_size == 0
        if @@gems_size < Gem.loaded_specs.size
          @@gems_size = Gem.loaded_specs.size
          jars.maybe_load_jars( Gem.loaded_specs )
        end
      end
    end
  end
end
