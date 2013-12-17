module JBundler
  class Vendor

    def initialize( dir )
      @dir = File.expand_path( dir )
    end

    def vendored?
      File.exists?( @dir ) && Dir[ File.join( @dir, '*' ) ].size > 0
    end

    def require_jars
      Dir[ File.join( @dir, '*' ) ].each do |f|
        require f
      end
    end

    def setup( classpath_file )
      classpath_file.require_classpath
      FileUtils.mkdir_p( @dir )
      JBUNDLER_CLASSPATH.each do |f|
        FileUtils.cp_a( f, File.join( @dir,
                                      File.basename( f ) ) )
      end
    end

  end
end

