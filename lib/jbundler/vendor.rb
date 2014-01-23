module JBundler
  class Vendor

    def initialize( dir )
      @dir = File.expand_path( dir )
    end

    def vendored?
      File.exists?( @dir ) && Dir[ File.join( @dir, '*' ) ].size > 0
    end

    def require_jars
      Dir[ File.join( @dir, '**', '*' ) ].each do |f|
        require f
      end
    end

    def clear
      FileUtils.mkdir_p( @dir )
      Dir[ File.join( @dir, '*' ) ].each do |f|
        FileUtils.rm_rf( f )
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

    def copy_jar( coord, file )
      target = File.join( *coord.sub( /:jar:/, '-') .split( /:/ ) )
      target_file = File.join( @dir, target ) + '.jar'
      FileUtils.mkdir_p( File.dirname( target_file ) )
      FileUtils.cp( file, target_file )
      puts "\t#{coord} to #{target}"
    end
  end
end

