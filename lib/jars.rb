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
  end

end
module Kernel
  
  unless respond_to? :require_without_jars
    def jars
      @jars||= Jars.new
    end
    alias :require_without_jars :require
    def require fn
      if require_without_jars fn
        @@gems_size ||= 0
        if @@gems_size < Gem.loaded_specs.size
          @@gems_size = Gem.loaded_specs.size
          jars.maybe_load_jars( Gem.loaded_specs )
        end
      end
    end
  end
end
