require 'jar_installer'
module JBundler
  class Vendor

    def initialize( dir )
      @dir = File.expand_path( dir )
    end

    def vendored?
      File.exists?( @dir ) && Dir[ File.join( @dir, '*' ) ].size > 0
    end

    def require_jars
      jars = File.join( @dir, 'jbundler.rb' )
      if File.exists?( jars )
        $LOAD_PATH << @dir unless $LOAD_PATH.include? @dir
        require jars
      else
        Dir[ File.join( @dir, '**', '*' ) ].each do |f|
          require f
        end
        Jars.freeze_loading
        true
      end
    end

    def clear
      FileUtils.mkdir_p( @dir )
      Dir[ File.join( @dir, '*' ) ].each do |f|
        FileUtils.rm_rf( f )
      end
    end

    def vendor_dependencies( deps )
      require_file = File.join( @dir, 'jbundler.rb' )
      Jars::JarInstaller.install_deps( deps, @dir, require_file, true ) do |f|
        f.puts
        f.puts 'Jars.freeze_loading'
      end
    end

    def setup( classpath_file )
      classpath_file.require_classpath
      FileUtils.mkdir_p( @dir )
      JBUNDLER_CLASSPATH.each do |f|
        FileUtils.cp( f, File.join( @dir,
                                    File.basename( f ) ) )
      end
    end
  end
end

