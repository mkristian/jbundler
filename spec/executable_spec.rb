load File.expand_path(File.join( File.dirname( __FILE__ ), 'setup.rb'))
require 'jbundler/executable'
require 'jbundler/config'
require 'fileutils'

describe JBundler::Executable do

  [ 
   'executable_only_java_sources',
   'executable_compile',
   'executable_no_compile'
  ].each do |exec_dir|
    
    let( exec_dir.to_sym ) do
      dir = File.join( File.dirname( File.expand_path( __FILE__ ) ),
                       exec_dir )
      java.lang.System.set_property( 'user.dir', dir )
      FileUtils.rm_rf( File.join( dir, 'target' ) )
      dir
    end

    it "should create #{exec_dir} jar" do
      skip 'rvm is not working properly' if ENV[ 'rvm_version' ]
      dir = eval "#{exec_dir}"

      FileUtils.chdir( dir ) do
      exec = JBundler::Executable.new( 'start.rb', 
                                       JBundler::Config.new,
                                       File.basename( dir ) == 'executable_compile',
                                       false,
                                       :default )
      exec.packit
      
      `java -jar target/executable/#{exec_dir}.jar`.must_equal 'hello world'
      end
    end
  end
end

#FileUtils.rm_rf( File.join( File.expand_path( __FILE__ ).sub( /_spec.rb/, '' ), 'target' ) )
