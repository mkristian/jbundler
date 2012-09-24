require 'rubygems/commands/install_command'
require 'jbundler/aether'
require 'maven/tools/coordinate'

class Gem::Commands::InstallCommand

  include Maven::Tools::Coordinate

  unless respond_to? :execute_without_jars
    alias :execute_without_jars :execute
    def execute
      begin
        execute_without_jars
      rescue Gem::SystemExitException => e
        if e.exit_code == 0
          gems.each do |g|
            gg = g.sub /-java/, ''
            name = gg.sub( /-[^-]+$/, '' )
            version = gg.sub( /^.*-/, '' )

            # just load the gem
            gem( name, version )

            spec = Gem.loaded_specs.values.detect { |s| s.full_name == g }
            spec.requirements.each do |req|
              req.split(/\n/).each do |r|
                coord = to_coordinate( r )
                if coord 
                  aether.add_artifact( "#{coord}" ) rescue nil
                end
              end
            end
            aether.resolve
            aether.classpath_array.each do |path|
              if require path
                warn "using #{path}"# if jb_config.verbose
                jb_classpath << path
              end
            end
          end
        else
          raise e
        end
      end
    end

    def gems
      @gems ||= []
    end

    alias :_s_a_y_ :say
    def say( arg )
      if arg =~ /^Successfully/
        arg.sub /([^ ]+$)/ do
          gems << $1
        end
      end
      _s_a_y_( arg )
    end

    private
    
    def jb_classpath
      @jb_cp ||= defined?(JBUNDLER_CLASSPATH) ? JBUNDLER_CLASSPATH.dup : []
    end

    def jb_config
      @_jb_c ||= JBundler::Config.new
    end

    def aether
      @_aether ||= JBundler::AetherRuby.new(jb_config)
    end
  end
end
